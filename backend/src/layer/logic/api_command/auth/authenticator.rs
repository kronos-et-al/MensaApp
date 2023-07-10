use sha2::{Digest, Sha512};

use crate::{
    interface::api_command::{AuthInfo, CommandError},
    util::Uuid,
};

use super::image_command_type::ImageCommandType;

const MEAL_RATING_COMMAND_NAME: &str = "setRating"; // TODO 

pub struct Authenticator {
    api_keys: Vec<String>,
}

impl Authenticator {
    #[must_use]
    pub fn new(api_keys: Vec<String>) -> Self {
        Self { api_keys }
    }

    pub fn authn_image_command(
        &self,
        auth_info: &AuthInfo,
        image_id: Uuid,
        image_command_type: ImageCommandType,
    ) -> Result<(), CommandError> {
        todo!()
    }


    pub fn authn_meal_rating_command(
        &self,
        auth_info: &AuthInfo,
        meal_id: Uuid,
        rating: u32,
    ) -> Result<(), CommandError> {
        let api_key = self.get_api_key(auth_info).ok_or(CommandError::BadAuth)?; // TODO more details in error
        let res = Sha512::new()
            .chain_update(MEAL_RATING_COMMAND_NAME)
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(meal_id)
            .chain_update(rating.to_le_bytes())
            .finalize();

        let provided_hash = hex::decode(&auth_info.hash).map_err(|_| CommandError::BadAuth)?;

        if res[..] == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth)
        }
    }

    pub fn authn_add_image_command(
        &self,
        auth_info: &AuthInfo,
        meal_id: Uuid,
        url: &String,
    ) -> Result<(), CommandError> {
        todo!()
    }

    fn get_api_key(&self, auth_info: &AuthInfo) -> Option<String> {
        self.api_keys
            .iter()
            .find(|key| key.starts_with(&auth_info.api_ident))
            .map(Clone::clone)
    }
}
