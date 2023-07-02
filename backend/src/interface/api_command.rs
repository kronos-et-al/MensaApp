//! This interface allows to execute API commands.

use std::error::Error;

use async_trait::async_trait;
use thiserror::Error;

use crate::util::{ReportReason, Uuid};

pub type Result<T> = std::result::Result<T, CommandError>;

/// Interface for accessing commands which can be triggered by an API.
#[async_trait]
pub trait Command {
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        auth_info: AuthInfo,
    ) -> Result<()>;

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()>;

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()>;

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()>;

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()>;

    /// Command to link an image to a meal.
    async fn add_image(&self, meal_id: Uuid, image_url: String, auth_info: AuthInfo) -> Result<()>;

    /// command to add a rating to a meal.
    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, auth_info: AuthInfo) -> Result<()>;
}

/// Structure containing all information necessary for authenticating a client.
pub struct AuthInfo {
    /// Id of client, chosen at random.
    pub client_id: Uuid,
    /// First 10 letters of api key.
    pub api_ident: String,
    /// SHA-512 hash of all request parameters, the client id and the name of the request.
    /// This hash has to be checked to authenticate a command.
    pub hash: String,
}

/// Enum describing the possible ways, a command can fail.
#[derive(Debug, Error)]
pub enum CommandError {
    /// Error marking an invalid authentication.
    #[error("invalid authentication information provided")]
    BadAuth,
    /// Error marking something went wrong internally.
    #[error("internal error ocurred")]
    InternalError(#[from] Box<dyn Error>),
}
