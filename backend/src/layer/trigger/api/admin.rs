//! Admin rest api functionality

use std::sync::Arc;

use axum::{
    debug_handler,
    extract::{Path, State},
    headers::{authorization::Basic, Authorization},
    http::HeaderValue,
    middleware::{self, Next},
    response::IntoResponse,
    routing::method_routing::get,
    Router, TypedHeader,
};
use hyper::{header::WWW_AUTHENTICATE, HeaderMap, Request, StatusCode};

use tracing::warn;

use crate::{
    interface::api_command::{Command, CommandError},
    util::Uuid,
};

#[derive(Clone)]
pub(super) struct AdminKey(String);

pub(super) type ArcCommand = Arc<dyn Command + Send + Sync>;

pub(super) fn admin_router(admin_key: String, command: ArcCommand) -> Router<()> {
    let admin_auth = middleware::from_fn_with_state(AdminKey(admin_key), admin_auth_middleware);
    // let router = Router::new()
    //     .route("/version", get(version))
    //     .route("/report/delete_image/:image_id", get(delete_image))
    //     .route("/report/verify_image/:image_id", get(verify_image))
    //     .layer(HandleErrorLayer::new(handle_error));

    Router::new()
        .route("/version", get(version))
        .route("/report/delete_image/:image_id", get(delete_image))
        .route("/report/verify_image/:image_id", get(verify_image))
        .layer(admin_auth)
        .with_state(command)
}

impl IntoResponse for CommandError {
    fn into_response(self) -> axum::response::Response {
        let error = self.to_string();
        warn!("On Admin API request: {error}");
        (StatusCode::INTERNAL_SERVER_ERROR, error).into_response()
    }
}

#[debug_handler]
async fn version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}

#[debug_handler]
async fn verify_image(
    State(command): State<ArcCommand>,
    Path(image_id): Path<Uuid>,
) -> Result<String, CommandError> {
    command.verify_image(image_id).await?;

    Ok(format!("Successfully verified image {image_id}"))
}

#[debug_handler]
async fn delete_image(
    State(command): State<ArcCommand>,
    Path(image_id): Path<Uuid>,
) -> Result<String, CommandError> {
    command.delete_image(image_id).await?;
    Ok(format!("Successfully deleted image {image_id}"))
}

const ADMIN_USER: &str = "admin";
const XXX_AUTHENTICATE_CONTENT: &str = "Basic realm=MensaKaAdmin";

fn unauthenticated() -> impl IntoResponse {
    let mut headers = HeaderMap::new();
    headers.insert(
        WWW_AUTHENTICATE,
        HeaderValue::from_str(XXX_AUTHENTICATE_CONTENT).expect("contains no invalid characters"),
    );
    (
        StatusCode::UNAUTHORIZED,
        headers,
        "Please authenticate to access the admin api!",
    )
}

pub(super) async fn admin_auth_middleware(
    creds: Option<TypedHeader<Authorization<Basic>>>,
    State(auth_key): State<AdminKey>,
    req: Request<axum::body::Body>,
    next: Next<axum::body::Body>,
) -> impl IntoResponse {
    let Some(creds) = creds else {
        return Err(unauthenticated());
    };

    if creds.0 .0.username() != ADMIN_USER || creds.0 .0.password() != auth_key.0 {
        return Err(unauthenticated());
    }

    Ok(next.run(req).await)
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod test {
    use std::{
        net::{Ipv4Addr, SocketAddr, SocketAddrV4},
        sync::Arc,
    };

    use axum::{http::HeaderValue, Server};
    use base64::Engine;
    use hyper::{header::AUTHORIZATION, HeaderMap, StatusCode};
    use reqwest::Client;

    use super::ADMIN_USER;
    use crate::{
        layer::trigger::api::{admin::admin_router, mock::CommandMock},
        util::Uuid,
    };

    #[tokio::test]
    async fn test_api() {
        let key: String = "asdasdasdasd".into();
        let command = Arc::new(CommandMock);

        let router = admin_router(key.clone(), command);
        let socket = SocketAddr::V4(SocketAddrV4::new(Ipv4Addr::LOCALHOST, 8081));
        println!("socket: {socket}");
        let server = Server::bind(&socket).serve(router.into_make_service());

        tokio::spawn(server);

        assert_eq!(
            StatusCode::UNAUTHORIZED,
            reqwest::get(format!("http://{socket}/version"))
                .await
                .unwrap()
                .status()
        );

        let auth_header = build_auth_string(ADMIN_USER, &key);
        let mut headers = HeaderMap::new();
        headers.insert(AUTHORIZATION, auth_header);
        let authed_client = Client::builder().default_headers(headers).build().unwrap();

        let version = authed_client
            .get(format!("http://{socket}/version"))
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();

        assert_eq!(env!("CARGO_PKG_VERSION"), version);

        let id = Uuid::default();

        assert_eq!(
            StatusCode::OK,
            authed_client
                .get(format!("http://{socket}/report/delete_image/{id}"))
                .send()
                .await
                .unwrap()
                .status()
        );

        assert_eq!(
            StatusCode::OK,
            authed_client
                .get(format!("http://{socket}/report/verify_image/{id}"))
                .send()
                .await
                .unwrap()
                .status()
        );

        assert_eq!(
            StatusCode::UNAUTHORIZED,
            authed_client
                .get(format!("http://{socket}/version"))
                .header(
                    AUTHORIZATION.to_string(),
                    build_auth_string(ADMIN_USER, "invalid")
                )
                .send()
                .await
                .unwrap()
                .status()
        );
        assert_eq!(
            StatusCode::UNAUTHORIZED,
            authed_client
                .get(format!("http://{socket}/version"))
                .header(
                    AUTHORIZATION.to_string(),
                    build_auth_string("wrong_user", &key)
                )
                .send()
                .await
                .unwrap()
                .status()
        );
    }

    fn build_auth_string(username: &str, password: &str) -> HeaderValue {
        let auth_string = format!("{username}:{password}");
        let auth_string = base64::engine::general_purpose::STANDARD.encode(auth_string);
        HeaderValue::from_str(&format!("Basic {auth_string}")).unwrap()
    }
}
