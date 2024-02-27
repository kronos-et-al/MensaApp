use async_graphql::SimpleObject;

use crate::util::Uuid;

/// Object containing all information about whether the current request was authenticated.
/// For more informatiun about request authentication, see <https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md>.
#[derive(SimpleObject, Debug)]
pub(in super::super) struct AuthInfo {
    /// The in authorization header specified client id if any.
    pub(crate) client_id: Option<Uuid>,
    /// Whether this request was authenticated.
    pub(crate) authenticated: bool,
    /// Provided api key identifier.
    pub(crate) api_ident: String,
    /// Provided HMAC hash over request body.
    pub(crate) hash: String,
    /// Error message when not authenticated.
    pub(crate) auth_error: Option<String>,
}

impl From<super::super::auth::AuthInfo> for AuthInfo {
    fn from(value: super::super::auth::AuthInfo) -> Self {
        Self {
            api_ident: value.api_ident,
            auth_error: value.authenticated.as_ref().err().map(|e| format!("{e:?}")),
            authenticated: value.authenticated.is_ok(),
            client_id: value.client_id,
            hash: value.hash,
        }
    }
}
