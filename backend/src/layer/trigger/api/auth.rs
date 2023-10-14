use async_graphql::{ComplexObject, SimpleObject};
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
use hyper::StatusCode;
use mime::Mime;
use sha2::Sha512;
use thiserror::Error;

use crate::{interface::persistent_data::model::ApiKey, util::Uuid};

pub(super) type Result<T> = std::result::Result<T, AuthError>;

const AUTH_MANUAL_URL: &str = "https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md";

#[derive(Debug, Error, Clone)]
pub enum AuthError {
    #[error(
        "No client id provided in authorization header. See {} for more details.",
        AUTH_MANUAL_URL
    )]
    MissingClientId,
    #[error("One of the queries/mutations you requested requires authentication. Your auth info: {0:?} \nSee {} for more details.", AUTH_MANUAL_URL)]
    MissingOrInvalidAuth(AuthInfo),
}

#[derive(Debug, Clone)]
pub enum AuthFailReason {
    NoAuthHeader,
    MissingApiIdentOrHash,
    HashNotInBase64,
    InvalidApiKey,
    HashNotMatching(Vec<u8>),
}

/// Structure containing all information necessary for authenticating a client.
#[derive(Debug, Clone, SimpleObject)]
#[graphql(complex)]
pub struct AuthInfo {
    // todo doc comments for graphql
    pub client_id: Option<Uuid>,
    #[graphql(skip)] // todo add later in some way?
    pub authenticated: std::result::Result<(), AuthFailReason>,
    pub api_ident: String,
    pub hash: String,
}

// todo move out of here
#[ComplexObject]
impl AuthInfo {
    async fn authenticated(&self) -> bool {
        self.authenticated.is_ok()
    }

    async fn auth_error(&self) -> Option<String> {
        self.authenticated.as_ref().err().map(|e| format!("{e:?}"))
    }
}

/// Structure containing all information necessary for authenticating a client.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(super) struct MensaAuthHeader {
    /// Id of client, chosen at random.
    pub(super) client_id: Uuid,
    /// First 10 letters of api key.
    pub(super) api_ident: String,
    /// SHA-512 hash of all request parameters, the client id and the name of the request.
    /// This hash has to be checked to authenticate a command.
    pub(super) hash: String,
}

impl Credentials for MensaAuthHeader {
    const SCHEME: &'static str = AUTH_TYPE;

    fn decode(value: &axum::http::HeaderValue) -> Option<Self> {
        value.to_str().ok().and_then(read_auth_from_header)
    }

    fn encode(&self) -> axum::http::HeaderValue {
        unimplemented!() // todo if necessary
    }
}

pub(super) async fn auth_middleware(
    content_type: Option<TypedHeader<ContentType>>,
    auth: Option<TypedHeader<Authorization<MensaAuthHeader>>>,
    extract::State(api_keys): extract::State<Vec<ApiKey>>,
    req: Request<axum::body::Body>,
    next: Next<axum::body::Body>,
) -> std::result::Result<impl IntoResponse, (StatusCode, String)> {
    let auth_header = auth.map(|a| a.0 .0);
    let (parts, body) = req.into_parts();
    let body_bytes = hyper::body::to_bytes(body).await.map_err(|e| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            format!("Could not read body: {e}"),
        )
    })?;

    let bytes_to_hash = if content_type
        .map(|c| Mime::from(c.0))
        .is_some_and(|mime| mime.essence_str() == mime::MULTIPART_FORM_DATA.essence_str())
    {
        // copy parts
        const MULTIPART_ERROR: fn() -> String =
            || String::from("error while inspecting multipart request");

        let mut parts_builder = request::Builder::new()
            .method(parts.method.clone())
            .uri(parts.uri.clone())
            .version(parts.version);
        parts_builder
            .headers_mut()
            .ok_or((StatusCode::INTERNAL_SERVER_ERROR, MULTIPART_ERROR()))?
            .extend(parts.headers.clone());
        let parts = parts_builder
            .body(())
            .map_err(|e| {
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    format!("{}: {}", MULTIPART_ERROR(), e),
                )
            })?
            .into_parts()
            .0;

        // inspect copy of multipart request
        let req = Request::from_parts(parts, hyper::Body::from(body_bytes.clone()));
        let mut multipart = axum::extract::Multipart::from_request(req, &())
            .await
            .map_err(|_| (StatusCode::INTERNAL_SERVER_ERROR, MULTIPART_ERROR()))?;

        let mut operations_bytes = None;

        while let Ok(Some(field)) = multipart.next_field().await {
            if field.name() == Some("operations") {
                operations_bytes = Some(
                    field
                        .bytes()
                        .await
                        .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?,
                );
                break;
            }
        }

        operations_bytes.ok_or((
            StatusCode::BAD_REQUEST,
            String::from("Multipart request needs `operations` part"),
        ))?
    } else {
        body_bytes.clone()
    };

    // check hash
    let auth = AuthInfo {
        client_id: auth_header.as_ref().map(|a| a.client_id),
        authenticated: authenticate(auth_header.as_ref(), &api_keys, &bytes_to_hash),
        api_ident: auth_header
            .as_ref()
            .map(|a| a.api_ident.clone())
            .unwrap_or_default(),
        hash: auth_header
            .as_ref()
            .map(|a| a.hash.clone())
            .unwrap_or_default(),
    };

    let mut req = Request::from_parts(parts, hyper::Body::from(body_bytes));
    req.extensions_mut().insert(auth);
    Ok(next.run(req).await)
}

fn authenticate(
    info: Option<&MensaAuthHeader>,
    api_keys: &[ApiKey],
    bytes_to_hash: &[u8],
) -> std::result::Result<(), AuthFailReason> {
    let auth = info.ok_or(AuthFailReason::NoAuthHeader)?;

    if auth.api_ident.is_empty() || auth.hash.is_empty() {
        return Err(AuthFailReason::MissingApiIdentOrHash);
    }

    let api_key = &api_keys
        .iter()
        .find(|k| k.key.starts_with(&auth.api_ident))
        .ok_or(AuthFailReason::InvalidApiKey)?
        .key;

    let mut hmac =
        Hmac::<Sha512>::new_from_slice(api_key.as_bytes()).expect("hmac can take keys of any size");
    hmac.update(bytes_to_hash);
    let hash = hmac.finalize().into_bytes().to_vec();

    let given_hash = STANDARD
        .decode(&auth.hash)
        .map_err(|_| AuthFailReason::HashNotInBase64)?;

    if hash == given_hash {
        Ok(())
    } else {
        Err(AuthFailReason::HashNotMatching(hash))
    }
}

const AUTH_TYPE: &str = "Mensa";
const AUTH_SEPARATOR: char = ':';

/// Parses and decodes the auth header into an [`AuthInfo`]
#[must_use]
fn read_auth_from_header(header: &str) -> Option<MensaAuthHeader> {
    let (auth_type, codeword) = header.split_once(' ')?;

    if auth_type != MensaAuthHeader::SCHEME {
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
