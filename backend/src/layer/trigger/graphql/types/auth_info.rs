use async_graphql::SimpleObject;

use crate::{interface::api_command, util::Uuid};

#[derive(SimpleObject)]
/// Information about the provided authentication information.
pub struct AuthInfo {
    /// My own user identifier.
    client_id: Uuid,
    /// The provided api key identifier (first 10 symbols only!).
    api_ident: String,
    /// The provided hash of a request.
    hash: String,
}

impl From<api_command::InnerAuthInfo> for AuthInfo {
    fn from(value: api_command::InnerAuthInfo) -> Self {
        Self {
            client_id: value.client_id,
            api_ident: value.api_ident,
            hash: value.hash,
        }
    }
}
