use async_trait::async_trait;
use sqlx::{Pool, Postgres, query_as};

use crate::{
    interface::persistent_data::{
        model::{ApiKey, ImageInfo},
        CommandDataAccess, Result,
    },
    util::{ReportReason, Uuid},
};

/// Class implementing all database requests arising from graphql manipulations.
pub struct PersistentCommandData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
impl CommandDataAccess for PersistentCommandData {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(&self, image_id: Uuid) -> Result<ImageInfo> {
        todo!()
    }
    /// Marks an image as hidden. Hidden images cant be seen by users.
    async fn hide_image(&self, image_id: Uuid) -> Result<()> {
        todo!()
    }
    /// Saves an image report
    async fn add_report(
        &self,
        image_id: Uuid,
        client_id: Uuid,
        reason: ReportReason,
    ) -> Result<()> {
        todo!()
    }
    /// Adds an upvote to the given image. An user can only down- or upvote an image.
    async fn add_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }
    /// Adds a downvote to the given image. An user can only down- or upvote an image.
    async fn add_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }
    /// Removes an upvote from the given image.
    async fn remove_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }
    /// Removes a downvote from the given image.
    async fn remove_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }
    /// Adds an image link to the database. The image will be related to the given meal.
    async fn link_image(
        &self,
        meal_id: Uuid,
        user_id: Uuid,
        image_hoster_id: String,
        url: String,
    ) -> Result<()> {
        todo!()
    }
    /// Adds a rating to the database. The rating will be related to the given meal and the given user.
    async fn add_rating(&self, meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()> {
        todo!()
    }

    /// Loads all api_keys from the database.
    async fn get_api_keys(&self) -> Result<Vec<ApiKey>> {
        todo!()
    }
}
