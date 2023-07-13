use base64::{engine::general_purpose::STANDARD, Engine};

use sha2::{Digest, Sha512};

use crate::{
    interface::api_command::{CommandError, InnerAuthInfo, Result},
    util::Uuid,
};

use super::image_command_type::ImageCommandType;

const MEAL_RATING_COMMAND_NAME: &str = "setRating"; // TODO
const ADD_IMAGE_COMMAND_NAME: &str = "addImage"; // TODO

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

    /// Authenticates image commands by checking if the given hash conforms with the given api key.
    /// # Errors
    /// [`CommandError::BadAuth`] is returned when authentication failed.
    pub fn authn_image_command(
        &self,
        auth_info: &InnerAuthInfo,
        image_id: Uuid,
        image_command_type: ImageCommandType,
    ) -> Result<()> {
        let report_reason = if let ImageCommandType::ReportImage(reason) = image_command_type {
            reason.to_string()
        } else {
            String::new()
        };

        let hash = self.calculate_hash(
            auth_info,
            &image_command_type.to_string(),
            &[&image_id, &report_reason],
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

    /// Authenticates the command for rating meals by checking if the given hash conforms with the given api key.
    /// # Errors
    /// [`CommandError::BadAuth`] is returned when authentication failed.
    pub fn authn_meal_rating_command(
        &self,
        auth_info: &InnerAuthInfo,
        meal_id: Uuid,
        rating: u32,
    ) -> Result<()> {
        let hash = self.calculate_hash(
            auth_info,
            MEAL_RATING_COMMAND_NAME,
            &[&meal_id, &rating.to_le_bytes()],
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

    /// Authenticates the command for linking images by checking if the given hash conforms with the given api key.
    /// # Errors
    /// [`CommandError::BadAuth`] is returned when authentication failed.
    pub fn authn_add_image_command(
        &self,
        auth_info: &InnerAuthInfo,
        meal_id: Uuid,
        url: &String,
    ) -> Result<()> {
        let hash = self.calculate_hash(auth_info, ADD_IMAGE_COMMAND_NAME, &[&meal_id, url])?;
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
        params: &[&dyn AsRef<[u8]>],
    ) -> Result<Vec<u8>> {
        let api_key = self.get_api_key(auth_info)?;
        let mut hasher = Sha512::new()
            .chain_update(request_name)
            .chain_update(auth_info.client_id)
            .chain_update(api_key);
        for param in params {
            hasher.update(param);
        }

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
