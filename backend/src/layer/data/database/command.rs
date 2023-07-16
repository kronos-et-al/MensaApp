use async_trait::async_trait;
use sqlx::{Pool, Postgres};

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
    async fn get_image_info(&self, image_id: Uuid) -> Result<ImageInfo> {
        todo!()
    }

    async fn hide_image(&self, image_id: Uuid) -> Result<()> {
        todo!()
    }

    async fn add_report(
        &self,
        image_id: Uuid,
        client_id: Uuid,
        reason: ReportReason,
    ) -> Result<()> {
        todo!()
    }

    async fn add_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }

    async fn add_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }

    async fn remove_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }

    async fn remove_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        todo!()
    }

    async fn link_image(
        &self,
        meal_id: Uuid,
        user_id: Uuid,
        image_hoster_id: String,
        url: String,
    ) -> Result<()> {
        todo!()
    }

    async fn add_rating(&self, meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()> {
        todo!()
    }

    async fn get_api_keys(&self) -> Result<Vec<ApiKey>> {
        let keys = sqlx::query_as!(ApiKey, "SELECT api_key as key, description FROM api_key")
            .fetch_all(&self.pool)
            .await?;

        Ok(keys)
    }
}
