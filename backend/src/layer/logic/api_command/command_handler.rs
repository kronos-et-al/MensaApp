use async_trait::async_trait;

use crate::{
    interface::{
        admin_notification::AdminNotification,
        api_command::{AuthInfo, Command, Result},
        image_hoster::ImageHoster,
        persistent_data::CommandDataAccess,
    },
    layer::logic::api_command::auth::authenticator::Authenticator,
    util::{ReportReason, Uuid},
};

pub struct CommandHandler {
    auth: Authenticator,
}

impl CommandHandler {
    pub async fn new(
        command_data: &dyn CommandDataAccess,
        admin_notification: &dyn AdminNotification,
        image_hoster: &dyn ImageHoster,
    ) -> Self {
        let keys: Vec<String> = command_data
            .get_api_keys()
            .await
            .expect("HELP!")
            .into_iter()
            .map(|x| x.key)
            .collect();
        Self {
            auth: Authenticator::new(keys),
        }
    }
}

#[async_trait]
impl Command for CommandHandler {
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        auth_info: AuthInfo,
    ) -> Result<()> {
        todo!()
    }

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to link an image to a meal.
    async fn add_image(&self, meal_id: Uuid, image_url: String, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }
}
