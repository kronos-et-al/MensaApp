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
) -> Result<(), CommandError> {
    command.verify_image(image_id).await
}

#[debug_handler]
async fn delete_image(
    State(command): State<ArcCommand>,
    Path(image_id): Path<Uuid>,
) -> Result<(), CommandError> {
    command.delete_image(image_id).await
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
