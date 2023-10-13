use async_graphql::SimpleObject;
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
use base64::{
    engine::general_purpose::{self, STANDARD},
    Engine,
};
use hmac::{Hmac, Mac};
use hyper::body::Bytes;
use mime::Mime;
use sha2::Sha512;
use thiserror::Error;
use tracing::warn;

use crate::{interface::persistent_data::model::ApiKey, util::Uuid};

pub type Result<T> = std::result::Result<T, AuthError>;

const AUTH_MANUAL_URL: &str = "https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md";

#[derive(Debug, Error, Clone)]
pub enum AuthError {
    #[error(
        "No client id provided in authorization header. See {} for more details.",
        AUTH_MANUAL_URL
    )]
    MissingClientId,
    #[error("One of the queries/mutations you requested requires authentication. See {} for more details.", AUTH_MANUAL_URL)]
    MissingOrInvalidAuth,
}

/// Structure containing all information necessary for authenticating a client.
#[derive(Debug, Clone, SimpleObject)]
pub struct AuthInfo {
    pub client_id: Option<Uuid>,
    pub authenticated: bool,
    pub api_ident: String,
    pub hash: String,
}

/// Structure containing all information necessary for authenticating a client.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MensaAuthHeader {
    /// Id of client, chosen at random.
    pub client_id: Uuid,
    /// First 10 letters of api key.
    pub api_ident: String,
    /// SHA-512 hash of all request parameters, the client id and the name of the request.
    /// This hash has to be checked to authenticate a command.
    pub hash: String,
}

impl Credentials for MensaAuthHeader {
    const SCHEME: &'static str = "Mensa";

    fn decode(value: &axum::http::HeaderValue) -> Option<Self> {
        value.to_str().ok().and_then(read_auth_from_header)
    }

    fn encode(&self) -> axum::http::HeaderValue {
        todo!() // todo if necessary
    }
}

pub(super) async fn auth_middleware(
    content_type: Option<TypedHeader<ContentType>>,
    auth: Option<TypedHeader<Authorization<MensaAuthHeader>>>,
    extract::State(api_keys): extract::State<Vec<ApiKey>>,
    req: Request<axum::body::Body>,
    next: Next<axum::body::Body>,
) -> impl IntoResponse {
    let auth_header = auth.map(|a| a.0 .0);
    let (parts, body) = req.into_parts();
    let body_bytes = hyper::body::to_bytes(body).await.unwrap();

    // todo error handling
    warn!("middleware");

    let bytes_to_hash = if content_type
        .map(|c| Mime::from(c.0))
        .is_some_and(|mime| mime.essence_str() == mime::MULTIPART_FORM_DATA.essence_str())
    {
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
        let req = Request::from_parts(parts, hyper::Body::from(body_bytes.clone()));
        let mut multipart = axum::extract::Multipart::from_request(req, &())
            .await
            .unwrap();

        let mut operations_bytes = Bytes::default();
        while let Ok(Some(field)) = multipart.next_field().await {
            if field.name() == Some("operations") {
                operations_bytes = field.bytes().await.unwrap();
            }
        }

        operations_bytes
    } else {
        body_bytes.clone()
    };

    // check hash
    let auth = AuthInfo {
        client_id: auth_header.as_ref().map(|a| a.client_id),
        authenticated: authenticate(auth_header.as_ref(), &api_keys, &bytes_to_hash).is_some(),
        api_ident: auth_header
            .as_ref()
            .map(|a| a.api_ident.to_owned())
            .unwrap_or_default(),
        hash: auth_header
            .as_ref()
            .map(|a| a.hash.to_owned())
            .unwrap_or_default(),
    };

    let mut req = Request::from_parts(parts, hyper::Body::from(body_bytes));
    req.extensions_mut().insert(auth);
    next.run(req).await
}

fn authenticate(
    info: Option<&MensaAuthHeader>,
    api_keys: &[ApiKey],
    bytes_to_hash: &[u8],
) -> Option<()> {
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
    hmac.update(bytes_to_hash);
    let hash = hmac.finalize().into_bytes().to_vec();

    let given_hash = STANDARD.decode(&auth.hash).ok()?;

    (hash == given_hash).then_some(())
}

// todo deduplicate
const AUTH_TYPE: &str = "Mensa";
const AUTH_SEPARATOR: char = ':';

/// Parses and decodes the auth header into an [`AuthInfo`]
#[must_use]
fn read_auth_from_header(header: &str) -> Option<MensaAuthHeader> {
    let (auth_type, codeword) = header.split_once(' ')?;

    if auth_type != AUTH_TYPE {
        return None;
    }

    let auth_message = general_purpose::STANDARD
        .decode(codeword)
        .ok()
        .and_then(|bytes| String::from_utf8(bytes).ok())?;

    let parts: Vec<&str> = auth_message.split(AUTH_SEPARATOR).collect();

    let client_id = Uuid::try_from(*parts.first()?).ok()?;
    let api_ident = *parts.get(1)?;
    let hash = *parts.get(2)?;

    Some(MensaAuthHeader {
        client_id,
        api_ident: api_ident.into(),
        hash: hash.into(),
    })
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use super::*;

    #[test]
    fn test_auth_info_parsing() {
        let api_indent = "abc";
        let hash = "1234";
        let client_id = Uuid::new_v4();
        let auth = format!(
            "{AUTH_TYPE} {}",
            general_purpose::STANDARD.encode(format!("{client_id}:{api_indent}:{hash}"))
        );

        let auth_info = read_auth_from_header(&auth).expect("valid auth info");
        assert_eq!(auth_info.client_id, client_id, "wrong client id");
        assert_eq!(auth_info.api_ident, api_indent, "wrong api indent");
        assert_eq!(auth_info.hash, hash, "wrong hash");
    }

    #[test]
    fn test_auth_info_parsing_client_only() {
        let api_indent = "";
        let hash = "";
        let client_id = Uuid::new_v4();
        let auth = format!(
            "{AUTH_TYPE} {}",
            general_purpose::STANDARD.encode(format!("{client_id}:{api_indent}:{hash}"))
        );

        let auth_info = read_auth_from_header(&auth).expect("valid auth info");
        assert_eq!(auth_info.client_id, client_id, "wrong client id");
        assert_eq!(auth_info.api_ident, api_indent, "wrong api indent");
        assert_eq!(auth_info.hash, hash, "wrong hash");
    }

    #[test]
    fn test_read_static_header() {
        // this header is valid and can be used for testing
        let header = "Mensa MWQ3NWQzODAtY2YwNy00ZWRiLTkwNDYtYTJkOTgxYmMyMTlkOmFiYzoxMjM=";
        let auth_info = read_auth_from_header(header);
        assert!(auth_info.is_some(), "could not read auth header");

        let expected_auth_info = Some(MensaAuthHeader {
            client_id: Uuid::try_from("1d75d380-cf07-4edb-9046-a2d981bc219d").unwrap(),
            api_ident: "abc".into(),
            hash: "123".into(),
        });
        assert_eq!(expected_auth_info, auth_info);
    }
}
