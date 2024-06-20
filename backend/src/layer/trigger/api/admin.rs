//! Admin rest api functionality

use std::sync::Arc;

use axum::{
    debug_handler,
    extract::State,
    headers::{authorization::Basic, Authorization},
    http::HeaderValue,
    middleware::Next,
    response::IntoResponse,
    routing::method_routing::get,
    Router, TypedHeader,
};
use hyper::{header::WWW_AUTHENTICATE, HeaderMap, Request, StatusCode};

use crate::interface::api_command::Command;

#[derive(Clone)]
pub(super) struct AdminKey(pub String);

pub(super) type ArcCommand = Arc<dyn Command + Send + Sync>;

pub(super) fn admin_router() -> Router<ArcCommand> {
    Router::new().route("/test", get(test_command))
}

#[debug_handler]
async fn test_command(
    State(command): State<ArcCommand>,
    body: Request<axum::body::Body>,
) -> &'static str {
    "working" // todo
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
