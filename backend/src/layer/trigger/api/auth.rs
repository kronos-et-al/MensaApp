use axum::{
    extract::{self, FromRequest},
    headers::{authorization::Credentials, Authorization, ContentType},
    http::{
        request::{self},
        Request,
    },
    middleware::Next,
    response::IntoResponse,
    TypedHeader,
};
use base64::{engine::general_purpose::STANDARD, Engine};
use hmac::{Hmac, Mac};
use hyper::body::Bytes;
use mime::Mime;
use sha2::Sha512;
use tracing::warn;

use crate::{
    interface::{
        api_command::{AuthInfo, InnerAuthInfo},
        persistent_data::model::ApiKey,
    },
    util::Uuid,
};

use super::util::read_auth_from_header;

impl Credentials for InnerAuthInfo {
    const SCHEME: &'static str = "Mensa";

    fn decode(value: &axum::http::HeaderValue) -> Option<Self> {
        value.to_str().ok().and_then(read_auth_from_header)
    }

    fn encode(&self) -> axum::http::HeaderValue {
        todo!() // todo if necessary
    }
}

#[derive(Debug, Clone)]
pub struct AuthInfo2 {
    // todo rename
    client_id: Option<Uuid>,
    authenticated: bool,
}

pub(super) async fn auth_middleware(
    TypedHeader(content_type): TypedHeader<ContentType>,
    auth: Option<TypedHeader<Authorization<InnerAuthInfo>>>,
    extract::State(api_keys): extract::State<Vec<ApiKey>>,
    req: Request<axum::body::Body>,
    next: Next<axum::body::Body>,
) -> impl IntoResponse {
    let auth: AuthInfo = auth.map(|a| a.0 .0);
    let (parts, body) = req.into_parts();
    let bytes = hyper::body::to_bytes(body).await.unwrap();

    let mime = Mime::from(content_type);

    // todo error handling
    warn!("middleware");

    let hash_bytes = if mime.essence_str() == mime::MULTIPART_FORM_DATA.essence_str() {
        // copy parts
        let mut parts_builder = request::Builder::new()
            .method(parts.method.clone())
            .uri(parts.uri.clone())
            .version(parts.version.clone());
        parts_builder
            .headers_mut()
            .unwrap()
            .extend(parts.headers.clone());
        let parts = parts_builder.body(()).unwrap().into_parts().0;

        // inspect copy of multipart request
        let req = Request::from_parts(parts, hyper::Body::from(bytes.clone()));
        let mut multipart = axum::extract::Multipart::from_request(req, &())
            .await
            .unwrap();

        let mut bytes = Bytes::default();
        while let Ok(Some(field)) = multipart.next_field().await {
            if field.name() == Some("operations") {
                bytes = field.bytes().await.unwrap();
            }
        }

        bytes
    } else {
        bytes.clone()
    };

    // check hash
    let auth2 = AuthInfo2 {
        client_id: auth.as_ref().map(|a| a.client_id),
        authenticated: authenticate(auth, &api_keys, &bytes).is_some(),
    };

    let mut req = Request::from_parts(parts, hyper::Body::from(bytes));
    req.extensions_mut().insert(auth2);
    next.run(req).await
}

fn authenticate(info: Option<InnerAuthInfo>, api_keys: &[ApiKey], body_bytes: &[u8]) -> Option<()> {
    // todo error messages
    let auth = info?;

    if auth.api_ident.is_empty() || !auth.hash.is_empty() {
        return None;
    }

    let api_key = &api_keys
        .iter()
        .find(|k| k.key.starts_with(&auth.api_ident))?
        .key;

    let mut hmac = Hmac::<Sha512>::new_from_slice(api_key.as_bytes()).ok()?;
    hmac.update(body_bytes);
    let hash = hmac.finalize().into_bytes().to_vec();

    let given_hash = STANDARD.decode(auth.hash).ok()?;

    (hash == given_hash).then_some(())
}
