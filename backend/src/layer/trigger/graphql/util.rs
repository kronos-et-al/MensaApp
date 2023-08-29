use async_graphql::Context;

use crate::{
    interface::{
        api_command::{AuthInfo, Command, InnerAuthInfo},
        persistent_data::RequestDataAccess,
    },
    util::Uuid,
};
use base64::{engine::general_purpose, Engine};

pub type DataBox = Box<dyn RequestDataAccess + Sync + Send + 'static>;
pub type CommandBox = Box<dyn Command + Sync + Send + 'static>;

pub trait ApiUtil {
    fn get_command(&self) -> &(dyn Command + Sync + Send);
    fn get_data_access(&self) -> &(dyn RequestDataAccess + Sync + Send);
    fn get_auth_info(&self) -> AuthInfo;
}

impl<'a> ApiUtil for Context<'a> {
    fn get_command(&self) -> &'a (dyn Command + Sync + Send) {
        self.data_unchecked::<CommandBox>().as_ref()
    }

    fn get_data_access(&self) -> &'a (dyn RequestDataAccess + Sync + Send) {
        self.data_unchecked::<DataBox>().as_ref()
    }

    fn get_auth_info(&self) -> AuthInfo {
        self.data::<AuthInfo>().iter().find_map(|i| (*i).clone())
    }
}

const AUTH_TYPE: &str = "Mensa";
const AUTH_SEPARATOR: char = ':';

/// Parses and decodes the auth header into an [`AuthInfo`]
#[must_use]
pub fn read_auth_from_header(header: &str) -> AuthInfo {
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

    Some(InnerAuthInfo {
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

        let expected_auth_info = Some(InnerAuthInfo {
            client_id: Uuid::try_from("1d75d380-cf07-4edb-9046-a2d981bc219d").unwrap(),
            api_ident: "abc".into(),
            hash: "123".into(),
        });
        assert_eq!(expected_auth_info, auth_info);
    }
}
