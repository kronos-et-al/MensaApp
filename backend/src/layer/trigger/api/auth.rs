//! Module responsible for authenticating graphql requests.
//! For more details, see <https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md>.

use std::{error::Error, fmt::Display, io::Cursor};

use axum::{
    body::to_bytes,
    extract::{self},
    http::Request,
    middleware::Next,
    response::IntoResponse,
};
use axum_extra::{
    headers::{authorization::Credentials, Authorization, ContentType},
    TypedHeader,
};
use base64::{
    engine::general_purpose::{self, STANDARD},
    Engine,
};
use hmac::{Hmac, Mac};
use hyper::{body::Bytes, StatusCode};
use mime::Mime;
use multer::{parse_boundary, Multipart};
use sha2::Sha512;
use thiserror::Error;

use crate::{interface::persistent_data::model::ApiKey, util::Uuid};

pub(super) type AuthResult<T> = Result<T, AuthError>;

const AUTH_DOC_URL: &str = "https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md";

/// Error indicating something went wrong with authentication.
#[derive(Debug, Error, Clone)]
pub enum AuthError {
    /// No client identifier was provided but the request requires one.
    #[error(
        "No client id provided in authorization header. See {} for more details.",
        AUTH_DOC_URL
    )]
    MissingClientId,
    /// No or invalid authentication provided but the request needs to be authenticated.
    #[error("One of the queries/mutations you requested requires authentication. Your auth info: {0:?} \nSee {url} for more details.", url = AUTH_DOC_URL)]
    MissingOrInvalidAuth(AuthInfo),
}

/// Reasons why authentication failed.
#[derive(Debug, Clone)]
pub enum AuthFailReason {
    /// No `Authorization` header was provided or header has wrong format.
    /// For more details see <https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md>.
    NoAuthHeader,
    /// Api identifier or hash was left empty.
    MissingApiIdentOrHash,
    /// Hash is no valid base 64 codeword.
    HashNotInBase64,
    /// Api key is not valid.
    InvalidApiKey,
    /// Provided HMAC hash does not match with request.
    HashNotMatching(Vec<u8>),
}

/// Structure containing all information necessary for authenticating a client.
#[derive(Debug, Clone)]
pub struct AuthInfo {
    /// Identifier of client making request, if provided.
    pub client_id: Option<Uuid>,
    /// Reason why authentication failed (if so).
    pub authenticated: Result<(), AuthFailReason>,
    /// Identifier of api key used for authentication.
    /// For more details see <https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md>.
    pub api_ident: String,
    /// User provided HMAC hash for request.
    pub hash: String,
}

impl Display for AuthInfo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let auth_status = match &self.authenticated {
            Ok(()) => "authenticated".into(),
            Err(e) => format!("unauthenticated ({e:?})"),
        };
        write!(
            f,
            "AuthInfo for client `{}`: {}, api_indent: `{}`, hash: `{}`",
            self.client_id.as_ref().map_or("-".into(), Uuid::to_string),
            auth_status,
            self.api_ident,
            self.hash
        )
    }
}

/// Structure containing all information necessary for authenticating a client.
/// These information can be read directly from the `Authorization` header.
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
        unimplemented!()
    }
}

#[derive(Error, Debug)]
pub(super) enum AuthMiddlewareError {
    #[error("could not read body: {0}")]
    UnableToReadBody(Box<dyn Error>),
    #[error("error inspecting multipart request: {0}")]
    MultipartError(#[from] multer::Error),
    #[error("multipart request needs `operations` part")]
    MissingOperationsPart,
}

impl IntoResponse for AuthMiddlewareError {
    fn into_response(self) -> axum::response::Response {
        (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()).into_response()
    }
}

pub(super) async fn auth_middleware(
    content_type: Option<TypedHeader<ContentType>>,
    auth: Option<TypedHeader<Authorization<MensaAuthHeader>>>,
    extract::State((body_limit, api_keys)): extract::State<(usize, Vec<ApiKey>)>,
    req: Request<axum::body::Body>,
    next: Next,
) -> Result<impl IntoResponse, AuthMiddlewareError> {
    let auth_header = auth.map(|a| a.0 .0);

    let (parts, body) = req.into_parts();
    let body_bytes = to_bytes(body, body_limit)
        .await
        .map_err(|e| AuthMiddlewareError::UnableToReadBody(Box::new(e)))?;

    let bytes_to_hash = match content_type {
        Some(TypedHeader(content_type)) if is_multipart(content_type.clone()) => {
            &extract_operation_bytes_from_multipart(&content_type, &body_bytes).await?
        }
        _ => &body_bytes,
    };

    let auth = AuthInfo {
        authenticated: authenticate(auth_header.as_ref(), &api_keys, bytes_to_hash),

        client_id: auth_header.as_ref().map(|a| a.client_id),
        api_ident: auth_header
            .as_ref()
            .map(|a| a.api_ident.clone())
            .unwrap_or_default(),
        hash: auth_header
            .as_ref()
            .map(|a| a.hash.clone())
            .unwrap_or_default(),
    };

    // run main request
    let body = axum::body::Body::from(body_bytes);
    let mut req = Request::from_parts(parts, body);
    req.extensions_mut().insert(auth);

    Ok(next.run(req).await)
}

fn is_multipart(content_type: ContentType) -> bool {
    Mime::from(content_type).essence_str() == mime::MULTIPART_FORM_DATA.essence_str()
}

async fn extract_operation_bytes_from_multipart(
    content_type: &ContentType,
    body_bytes: &Bytes,
) -> Result<Bytes, AuthMiddlewareError> {
    let boundary = parse_boundary(content_type.to_string())?;

    let mut multipart = Multipart::with_reader(Cursor::new(body_bytes), boundary);

    let mut operations_bytes = None;

    while let Some(field) = multipart.next_field().await? {
        if field.name() == Some("operations") {
            operations_bytes = Some(field.bytes().await?);
            break;
        }
    }

    operations_bytes.ok_or(AuthMiddlewareError::MissingOperationsPart)
}

fn authenticate(
    info: Option<&MensaAuthHeader>,
    api_keys: &[ApiKey],
    bytes_to_hash: &[u8],
) -> Result<(), AuthFailReason> {
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
        Hmac::<Sha512>::new_from_slice(api_key.as_bytes()).expect("HMAC can take keys of any size");
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
    use std::str::FromStr;

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

    #[test]
    fn test_is_multipart() {
        assert!(!is_multipart(ContentType::jpeg()));
        assert!(!is_multipart(ContentType::form_url_encoded()));

        let content_type = ContentType::from_str("multipart/form-data").unwrap();
        assert!(is_multipart(content_type));

        let content_type = ContentType::from_str("multipart/form-data; extra=abc").unwrap();
        assert!(is_multipart(content_type));
    }

    #[tokio::test]
    async fn test_extract_operation_bytes() {
        let body = b"--boundary\r\nContent-Disposition: form-data; name=\"operations\"\r\n\r\n{\"operationName\":null,\"variables\":{\"mealId\":\"bd3c88f9-5dc8-4773-85dc-53305930e7b6\",\"image\":null},\"query\":\"mutation LinkImage($mealId: UUID!, $image: Upload!) {\\n  __typename\\n  addImage(mealId: $mealId, image: $image)\\n}\"}\r\n--boundary\r\nContent-Disposition: form-data; name=\"map\"\r\n\r\n{\"0\":[\"variables.image\"]}\r\n--boundary\r\ncontent-type: text/plain; charset=utf-8\r\ncontent-disposition: form-data; name=\"0\"; filename=\"a\"\r\n\r\nimage\r\n--boundary--".as_ref();

        let operations = Bytes::from(
            r#"{"operationName":null,"variables":{"mealId":"bd3c88f9-5dc8-4773-85dc-53305930e7b6","image":null},"query":"mutation LinkImage($mealId: UUID!, $image: Upload!) {\n  __typename\n  addImage(mealId: $mealId, image: $image)\n}"}"#,
        );

        let content_type = ContentType::from_str("multipart/form-data; boundary=boundary").unwrap();
        let bytes = Bytes::from(body);

        let extracted = extract_operation_bytes_from_multipart(&content_type, &bytes)
            .await
            .unwrap();

        assert_eq!(operations, extracted);
    }

    #[tokio::test]
    async fn test_extract_operation_bytes_large() {
        let body = [b"--boundary\r\nContent-Disposition: form-data; name=\"operations\"\r\n\r\n{\"operationName\":null,\"variables\":{\"mealId\":\"bd3c88f9-5dc8-4773-85dc-53305930e7b6\",\"image\":null},\"query\":\"mutation LinkImage($mealId: UUID!, $image: Upload!) {\\n  __typename\\n  addImage(mealId: $mealId, image: $image)\\n}\"}\r\n--boundary\r\nContent-Disposition: form-data; name=\"map\"\r\n\r\n{\"0\":[\"variables.image\"]}\r\n--boundary\r\ncontent-type: image/jpeg\r\ncontent-disposition: form-data; name=\"0\"; filename=\"a\"\r\n\r\n".as_ref(), 
        include_bytes!("test_data/test_real.jpg").as_ref(),
        b"\r\n--boundary--".as_ref()].concat();

        let operations = Bytes::from(
            r#"{"operationName":null,"variables":{"mealId":"bd3c88f9-5dc8-4773-85dc-53305930e7b6","image":null},"query":"mutation LinkImage($mealId: UUID!, $image: Upload!) {\n  __typename\n  addImage(mealId: $mealId, image: $image)\n}"}"#,
        );

        let content_type = ContentType::from_str("multipart/form-data; boundary=boundary").unwrap();
        let bytes = Bytes::from(body);

        let extracted = extract_operation_bytes_from_multipart(&content_type, &bytes)
            .await
            .unwrap();

        assert_eq!(operations, extracted);
    }

    #[test]
    fn test_authenticate() {
        assert!(authenticate(None, &[], &[]).is_err());

        let bytes = &[8u8, 123u8, 11u8, 61u8, 222u8];
        let api_key = "1234567890";

        let hash = Hmac::<Sha512>::new_from_slice(api_key.as_bytes())
            .unwrap()
            .chain_update(bytes)
            .finalize()
            .into_bytes()
            .to_vec();
        let hash64 = base64::prelude::BASE64_STANDARD.encode(hash);

        let header = MensaAuthHeader {
            client_id: Uuid::from_str("e997c2e3-68e1-4b6d-b328-4adcd573c834").unwrap(),
            api_ident: "123".into(),
            hash: hash64,
        };

        let key_list = &[
            ApiKey {
                description: String::new(),
                key: String::from("abc"),
            },
            ApiKey {
                description: String::new(),
                key: api_key.into(),
            },
        ];

        assert!(authenticate(Some(&header), key_list, bytes).is_ok());
    }
}
