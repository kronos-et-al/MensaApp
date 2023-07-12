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
        // TODO remove duplication
        let api_key = self
            .get_api_key(auth_info)
            .ok_or(CommandError::BadAuth(auth_info.clone()))?;
        let res = Sha512::new()
            .chain_update(image_command_type.to_string())
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(image_id)
            .finalize();

        let provided_hash = STANDARD
            .decode(&auth_info.hash)
            .map_err(|_| CommandError::BadAuth(auth_info.clone()))?;

        if res[..] == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth(auth_info.clone()))
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
        let api_key = self
            .get_api_key(auth_info)
            .ok_or(CommandError::BadAuth(auth_info.clone()))?;
        let res = Sha512::new()
            .chain_update(MEAL_RATING_COMMAND_NAME)
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(meal_id)
            .chain_update(rating.to_le_bytes())
            .finalize();

        let provided_hash = STANDARD
            .decode(&auth_info.hash)
            .map_err(|_| CommandError::BadAuth(auth_info.clone()))?;

        if res[..] == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth(auth_info.clone()))
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
        let api_key = self
            .get_api_key(auth_info)
            .ok_or(CommandError::BadAuth(auth_info.clone()))?;
        let res = Sha512::new()
            .chain_update(ADD_IMAGE_COMMAND_NAME)
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(meal_id)
            .chain_update(url)
            .finalize();

        let provided_hash = STANDARD
            .decode(&auth_info.hash)
            .map_err(|_| CommandError::BadAuth(auth_info.clone()))?;

        if res[..] == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth(auth_info.clone()))
        }
    }

    fn get_api_key(&self, auth_info: &InnerAuthInfo) -> Option<String> {
        self.api_keys
            .iter()
            .find(|key| key.starts_with(&auth_info.api_ident))
            .map(Clone::clone)
    }
}
