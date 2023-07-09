use crate::{
    interface::api_command::{AuthInfo, CommandError},
    util::Uuid,
};

use super::image_command_type::ImageCommandType;

pub struct Authenticator {
    api_keys: Vec<String>,
}

impl Authenticator {
    #[must_use] pub fn new(api_keys: Vec<String>) -> Self {
        Self {
            api_keys,
        }
    }

    pub fn authn_image_command(
        &self,
        auth_info: AuthInfo,
        image_id: Uuid,
        image_command_type: ImageCommandType,
    ) -> Result<(), CommandError> {
        todo!()
    }

    pub fn authn_meal_rating_command(
        &self,
        auth_info: AuthInfo,
        meal_id: Uuid,
        rating: u32,
    ) -> Result<(), CommandError> {
        todo!()
    }

    pub fn authn_add_image_command(
        &self,
        auth_info: AuthInfo,
        meal_id: Uuid,
        url: String,
    ) -> Result<(), CommandError> {
        todo!()
    }
}
