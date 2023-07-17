use base64::{engine::general_purpose::STANDARD, Engine};

use sha2::{Digest, Sha512};

use crate::interface::api_command::{CommandError, InnerAuthInfo, Result};

use super::command_type::CommandType;

/// Class for authenticating commands.
pub struct Authenticator {
    api_keys: Vec<String>,
}

impl Authenticator {
    /// Creates a new object which authenticates requests against the given list of valid api keys.
    #[must_use]
    pub fn new(api_keys: Vec<String>) -> Self {
        Self { api_keys }
    }

    /// Authenticates a commands by checking if the given hash conforms with the given api key.
    /// # Errors
    /// - [`CommandError::BadAuth`] is returned when authentication failed.
    pub fn authn_command(
        &self,
        auth_info: &InnerAuthInfo,
        command_type: &CommandType,
    ) -> Result<()> {
        let hash = self.calculate_hash(
            auth_info,
            &command_type.to_string(),
            command_type.get_bytes(),
        )?;
        let provided_hash = Self::get_provided_hash(auth_info)?;

        if hash == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth(format!(
                "hash not matching: {auth_info}"
            )))
        }
    }

    fn calculate_hash(
        &self,
        auth_info: &InnerAuthInfo,
        request_name: &str,
        params: Vec<u8>,
    ) -> Result<Vec<u8>> {
        let api_key = self.get_api_key(auth_info)?;
        let hasher = Sha512::new()
            .chain_update(request_name)
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(params);

        Ok(Vec::from(&hasher.finalize()[..]))
    }

    fn get_provided_hash(auth_info: &InnerAuthInfo) -> Result<Vec<u8>> {
        STANDARD
            .decode(&auth_info.hash)
            .map_err(|_| CommandError::BadAuth(format!("could not decode hash: {auth_info}")))
    }

    fn get_api_key(&self, auth_info: &InnerAuthInfo) -> Result<String> {
        self.api_keys
            .iter()
            .find(|key| key.starts_with(&auth_info.api_ident))
            .map(Clone::clone)
            .ok_or(CommandError::BadAuth(format!(
                "no matching api key found for `{}`",
                auth_info.api_ident
            )))
    }
}
