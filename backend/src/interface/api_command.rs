//! This interface allows to execute API commands.

use std::sync::Arc;

use async_trait::async_trait;
use thiserror::Error;

use crate::{
    layer::logic::api_command::image_preprocessing::ImagePreprocessingError,
    util::{ReportReason, Uuid},
};

use super::{
    admin_notification::MailError, image_storage, image_validation, persistent_data::DataError,
};

/// Result returned from commands, potentially containing a [`CommandError`].
pub type Result<T> = std::result::Result<T, CommandError>;

/// Interface for accessing commands which can be triggered by an API.
#[async_trait]
pub trait Command: Send + Sync {
    /// Command to report an image. It also checks whether the image shall be hid.
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        client_id: Uuid,
    ) -> Result<()>;

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()>;

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()>;

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()>;

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()>;

    /// Command to link an image to a meal.
    async fn add_image(
        &self,
        meal_id: Uuid,
        image_type: Option<String>,
        image_file: Vec<u8>,
        client_id: Uuid,
    ) -> Result<()>;

    /// command to add a rating to a meal.
    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, client_id: Uuid) -> Result<()>;

    /// Marks an image as verified.
    async fn verify_image(&self, image_id: Uuid) -> Result<()>;

    /// Deletes an image.
    async fn delete_image(&self, image_id: Uuid) -> Result<()>;
}

#[async_trait]
impl<C: Command> Command for Arc<C> {
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        client_id: Uuid,
    ) -> Result<()> {
        Self::as_ref(self)
            .report_image(image_id, reason, client_id)
            .await
    }

    async fn add_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        Self::as_ref(self)
            .add_image_upvote(image_id, client_id)
            .await
    }

    async fn add_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        Self::as_ref(self)
            .add_image_downvote(image_id, client_id)
            .await
    }

    async fn remove_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        Self::as_ref(self)
            .remove_image_upvote(image_id, client_id)
            .await
    }

    async fn remove_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        Self::as_ref(self)
            .remove_image_downvote(image_id, client_id)
            .await
    }

    async fn add_image(
        &self,
        meal_id: Uuid,
        image_type: Option<String>,
        image_file: Vec<u8>,
        client_id: Uuid,
    ) -> Result<()> {
        Self::as_ref(self)
            .add_image(meal_id, image_type, image_file, client_id)
            .await
    }

    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, client_id: Uuid) -> Result<()> {
        Self::as_ref(self)
            .set_meal_rating(meal_id, rating, client_id)
            .await
    }

    async fn verify_image(&self, image_id: Uuid) -> Result<()> {
        Self::as_ref(self).verify_image(image_id).await
    }

    async fn delete_image(&self, image_id: Uuid) -> Result<()> {
        Self::as_ref(self).delete_image(image_id).await
    }
}

/// Enum describing the possible ways, a command can fail.
#[derive(Debug, Error)]
pub enum CommandError {
    /// Error marking an invalid authentication.
    #[error("invalid authentication information provided: {0}")]
    BadAuth(String),
    /// Error marking missing authentication.
    #[error("no authentication information provided")]
    NoAuth,
    /// Error marking something went wrong with the data.
    #[error("Data error occurred: {0}")]
    DataError(#[from] DataError),
    /// Error happened during image preprocessing
    #[error("Error during image preprocessing occured: {0}")]
    ImagePreprocessingError(#[from] ImagePreprocessingError),
    /// Error ocurred while saving image.
    #[error("Error while accessing image storage: {0}")]
    ImageStorageError(#[from] image_storage::ImageError),
    /// Error while image verification.
    #[error("Image could not be verified: {0}")]
    ImageValidationError(#[from] image_validation::ImageValidationError),
    /// Error while trying to send aan admin notification.
    #[error("Administrator could not be notified: {0}")]
    AdminNotificationError(#[from] MailError),
}
