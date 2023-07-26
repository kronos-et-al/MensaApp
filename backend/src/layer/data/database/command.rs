use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{ApiKey, Image},
        CommandDataAccess, Result,
    },
    null_error,
    util::{ReportReason, Uuid},
};

/// Class implementing all database requests arising from graphql manipulations.
pub struct PersistentCommandData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl CommandDataAccess for PersistentCommandData {
    async fn get_image_info(&self, image_id: Uuid) -> Result<Image> {
        let record = sqlx::query!(
            r#"
            SELECT approved, link_date as upload_date, report_count, url,
            upvotes, downvotes, id as image_hoster_id, image_id, rank
            FROM image_detail
            WHERE image_id = $1
            "#,
            image_id
        )
        .fetch_one(&self.pool)
        .await?;

        Ok(Image {
            approved: null_error!(record.approved),
            url: null_error!(record.url),
            rank: null_error!(record.rank),
            report_count: u32::try_from(null_error!(record.report_count))?,
            upload_date: null_error!(record.upload_date),
            downvotes: u32::try_from(null_error!(record.downvotes))?,
            upvotes: u32::try_from(null_error!(record.upvotes))?,
            id: null_error!(record.image_id),
            image_hoster_id: null_error!(record.image_hoster_id),
        })
    }

    async fn hide_image(&self, image_id: Uuid) -> Result<()> {
        sqlx::query!(
            "UPDATE image SET currently_visible = false WHERE image_id = $1",
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn add_report(
        &self,
        image_id: Uuid,
        client_id: Uuid,
        reason: ReportReason,
    ) -> Result<()> {
        sqlx::query!(
            "INSERT INTO image_report (image_id, user_id, reason) VALUES ($1, $2, $3)",
            image_id,
            client_id,
            reason as _
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn add_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        sqlx::query!(
            "INSERT INTO image_rating (user_id, image_id, rating) VALUES ($1, $2, 1)",
            user_id,
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn add_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        sqlx::query!(
            "INSERT INTO image_rating (user_id, image_id, rating) VALUES ($1, $2, -1)",
            user_id,
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn remove_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        sqlx::query!(
            "DELETE FROM image_rating WHERE user_id = $1 AND image_id = $2 AND rating = 1",
            user_id,
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn remove_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        sqlx::query!(
            "DELETE FROM image_rating WHERE user_id = $1 AND image_id = $2 AND rating = -1",
            user_id,
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn link_image(
        &self,
        meal_id: Uuid,
        user_id: Uuid,
        image_hoster_id: String,
        url: String,
    ) -> Result<()> {
        sqlx::query!(
            "INSERT INTO image (user_id, food_id, id, url) VALUES ($1, $2, $3, $4)",
            user_id,
            meal_id,
            image_hoster_id,
            url
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn add_rating(&self, meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()> {
        sqlx::query!(
            "INSERT INTO meal_rating (user_id, food_id, rating) VALUES ($1, $2, $3::smallint)",
            user_id,
            meal_id,
            i16::try_from(rating)?
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn get_api_keys(&self) -> Result<Vec<ApiKey>> {
        let keys = sqlx::query_as!(ApiKey, "SELECT api_key as key, description FROM api_key")
            .fetch_all(&self.pool)
            .await?;

        Ok(keys)
    }
}
