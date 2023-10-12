//! Module responsible for handling database requests for commands.
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
#[derive(Debug)]
pub struct PersistentCommandData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl CommandDataAccess for PersistentCommandData {
    async fn get_image_info(&self, image_id: Uuid) -> Result<Image> {
        let record = sqlx::query!(
            r#"
            SELECT approved, link_date as upload_date, report_count,
            upvotes, downvotes, image_id, rank
            FROM image_detail
            WHERE image_id = $1
            ORDER BY image_id
            "#,
            image_id
        )
        .fetch_one(&self.pool)
        .await?;

        Ok(Image {
            approved: null_error!(record.approved),
            rank: null_error!(record.rank),
            report_count: u32::try_from(null_error!(record.report_count))?,
            upload_date: null_error!(record.upload_date),
            downvotes: u32::try_from(null_error!(record.downvotes))?,
            upvotes: u32::try_from(null_error!(record.upvotes))?,
            id: null_error!(record.image_id),
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
            "
            INSERT INTO image_rating (user_id, image_id, rating) 
            VALUES ($1, $2, 1) 
            ON CONFLICT (user_id, image_id) 
            DO UPDATE SET rating = 1
            ",
            user_id,
            image_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn add_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()> {
        sqlx::query!(
            "
            INSERT INTO image_rating (user_id, image_id, rating) 
            VALUES ($1, $2, -1)
            ON CONFLICT (user_id, image_id) 
            DO UPDATE SET rating = -1
            ",
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

    async fn link_image(&self, meal_id: Uuid, user_id: Uuid) -> Result<Uuid> {
        sqlx::query_scalar!(
            "INSERT INTO image (user_id, food_id) VALUES ($1, $2)
            RETURNING (image_id)",
            user_id,
            meal_id,
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn revert_link_image(&self, image_id: Uuid) -> Result<()> {
        sqlx::query!("DELETE FROM image WHERE image_id = $1", image_id)
            .execute(&self.pool)
            .await?;
        Ok(())
    }

    async fn add_rating(&self, meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()> {
        sqlx::query!(
            "
            INSERT INTO meal_rating (user_id, food_id, rating) 
            VALUES ($1, $2, $3::smallint)
            ON CONFLICT (user_id, food_id) 
            DO UPDATE SET rating = $3::smallint
            ",
            user_id,
            meal_id,
            i16::try_from(rating)?
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn get_api_keys(&self) -> Result<Vec<ApiKey>> {
        let keys = sqlx::query_as!(
            ApiKey,
            "SELECT api_key as key, description FROM api_key ORDER BY api_key"
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(keys)
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use super::*;
    use chrono::Local;
    use sqlx::PgPool;

    use crate::util::Uuid;

    const WRONG_UUID: Uuid = Uuid::from_u128(7u128);

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_get_image_info(pool: PgPool) {
        let command = PersistentCommandData { pool };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();

        let image_info = command.get_image_info(image_id).await.unwrap();
        assert_eq!(image_info, provide_dummy_image());
        assert!(command.get_image_info(WRONG_UUID).await.is_err());
    }

    fn provide_dummy_image() -> Image {
        Image {
            id: Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap(),
            rank: 0.5,
            downvotes: 0,
            upvotes: 0,
            approved: false,
            upload_date: Local::now().date_naive(),
            report_count: 0,
        }
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_hide_image(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();

        let hidden_images = number_of_hidden_images(&pool).await;
        assert!(command.hide_image(image_id).await.is_ok());
        assert_eq!(number_of_hidden_images(&pool).await, hidden_images + 1);
        assert!(command.hide_image(image_id).await.is_ok());
        assert_eq!(number_of_hidden_images(&pool).await, hidden_images + 1);
    }

    async fn number_of_hidden_images(pool: &PgPool) -> usize {
        sqlx::query!("SELECT * FROM image WHERE currently_visible = false")
            .fetch_all(pool)
            .await
            .unwrap()
            .len()
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_add_report(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let client_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();
        let reason = ReportReason::Advert;

        let reports = number_of_reports(&pool).await;
        assert!(command
            .add_report(image_id, client_id, reason)
            .await
            .is_ok());
        assert_eq!(number_of_reports(&pool).await, reports + 1);
        assert!(command
            .add_report(image_id, client_id, reason)
            .await
            .is_err());
        assert!(command
            .add_report(WRONG_UUID, client_id, reason)
            .await
            .is_err());
        assert_eq!(number_of_reports(&pool).await, reports + 1);
    }

    async fn number_of_reports(pool: &PgPool) -> usize {
        sqlx::query!("SELECT image_id FROM image_report")
            .fetch_all(pool)
            .await
            .unwrap()
            .len()
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_add_upvote(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        let upvotes = number_of_votes(&pool, 1).await;
        assert!(command.add_upvote(image_id, user_id).await.is_ok());
        assert_eq!(number_of_votes(&pool, 1).await, upvotes + 1);
        assert!(command.add_upvote(image_id, user_id).await.is_ok());
        assert!(command.add_upvote(WRONG_UUID, user_id).await.is_err());
        assert_eq!(number_of_votes(&pool, 1).await, upvotes + 1);
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_add_downvote(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        let downvotes = number_of_votes(&pool, -1).await;
        assert!(command.add_downvote(image_id, user_id).await.is_ok());
        assert_eq!(number_of_votes(&pool, -1).await, downvotes + 1);
        assert!(command.add_downvote(image_id, user_id).await.is_ok());
        assert!(command.add_downvote(WRONG_UUID, user_id).await.is_err());
        assert_eq!(number_of_votes(&pool, -1).await, downvotes + 1);
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_override_votes(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        assert!(command.add_upvote(image_id, user_id).await.is_ok());
        assert!(command.add_downvote(image_id, user_id).await.is_ok());

        let vote = sqlx::query_scalar!(
            "SELECT rating FROM image_rating WHERE image_id = $1 AND user_id = $2",
            image_id,
            user_id,
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(vote, -1);

        assert!(command.add_upvote(image_id, user_id).await.is_ok());
        let vote = sqlx::query_scalar!(
            "SELECT rating FROM image_rating WHERE image_id = $1 AND user_id = $2",
            image_id,
            user_id,
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(vote, 1);
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_remove_upvote(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        let upvotes = number_of_votes(&pool, 1).await;
        assert!(command.remove_upvote(image_id, user_id).await.is_ok());
        let upvotes = usize::max(upvotes, 1) - 1;
        assert_eq!(number_of_votes(&pool, 1).await, upvotes);
        assert!(command.remove_upvote(image_id, user_id).await.is_ok());
        assert!(command.remove_upvote(WRONG_UUID, user_id).await.is_ok());
        assert_eq!(number_of_votes(&pool, 1).await, upvotes);
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_remove_downvote(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        let downvotes = number_of_votes(&pool, -1).await;
        assert!(command.remove_downvote(image_id, user_id).await.is_ok());
        let downvotes = usize::max(downvotes, 1) - 1;
        assert_eq!(number_of_votes(&pool, -1).await, downvotes);
        assert!(command.remove_downvote(image_id, user_id).await.is_ok());
        assert!(command.remove_downvote(WRONG_UUID, user_id).await.is_ok());
        assert_eq!(number_of_votes(&pool, -1).await, downvotes);
    }

    async fn number_of_votes(pool: &PgPool, rating: i16) -> usize {
        sqlx::query!(
            "SELECT image_id FROM image_rating WHERE rating = $1",
            rating
        )
        .fetch_all(pool)
        .await
        .unwrap()
        .len()
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_link_image(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();
        let meal_id = Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap();

        let images = number_of_images(&pool).await;
        assert!(command.link_image(meal_id, user_id).await.is_ok());
        assert_eq!(number_of_images(&pool).await, images + 1);
        // TBD is it allowed to link an image multiple times?
        // assert!(command
        //     .link_image(
        //         meal_id,
        //         user_id,
        //         image_hoster_id.to_string(),
        //         url.to_string()
        //     )
        //     .await
        //     .is_ok());
        assert!(command.link_image(WRONG_UUID, user_id).await.is_err());
        assert_eq!(number_of_images(&pool).await, images + 1);
    }

    async fn number_of_images(pool: &PgPool) -> usize {
        sqlx::query!("SELECT * FROM image")
            .fetch_all(pool)
            .await
            .unwrap()
            .len()
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_revert_link_image(pool: PgPool) {
        let old_num = number_of_images(&pool).await;
        let command = PersistentCommandData { pool: pool.clone() };
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        command.revert_link_image(image_id).await.unwrap();

        let new_num = number_of_images(&pool).await;
        assert_eq!(new_num, old_num - 1);
    }

    #[sqlx::test(fixtures("meal", "meal_rating"))]
    async fn test_add_rating(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };
        let meal_id = Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let user_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();
        let rated_user_id = Uuid::parse_str("0562269b-8c46-4d5f-9749-25f93c062748").unwrap();
        let rating = 5;

        let ratings = number_of_ratings(&pool).await;
        assert!(command.add_rating(meal_id, user_id, rating).await.is_ok());
        assert_eq!(number_of_ratings(&pool).await, ratings + 1);
        // overwriting rating
        assert!(command.add_rating(meal_id, user_id, rating).await.is_ok());
        assert!(command
            .add_rating(WRONG_UUID, user_id, rating)
            .await
            .is_err());
        assert!(command
            .add_rating(meal_id, user_id, u32::MAX)
            .await
            .is_err());
        assert_eq!(number_of_ratings(&pool).await, ratings + 1);

        // update rating
        command.add_rating(meal_id, rated_user_id, 1).await.unwrap();

        let rating = sqlx::query_scalar!(
            "SELECT rating FROM meal_rating WHERE user_id = $1 AND food_id = $2",
            rated_user_id,
            meal_id
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(1, rating);
    }

    async fn number_of_ratings(pool: &PgPool) -> usize {
        sqlx::query!("SELECT * FROM meal_rating")
            .fetch_all(pool)
            .await
            .unwrap()
            .len()
    }

    #[sqlx::test(fixtures("api_key"))]
    async fn test_get_api_keys(pool: PgPool) {
        let command = PersistentCommandData { pool: pool.clone() };

        assert!(command.get_api_keys().await.is_ok());
        assert_eq!(
            command.get_api_keys().await.unwrap(),
            provide_dummy_api_keys()
        );
    }

    fn provide_dummy_api_keys() -> Vec<ApiKey> {
        vec![
            ApiKey {
                key: "abc".into(),
                description: String::new(),
            },
            ApiKey {
                key: "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into(),
                description: String::new(),
            },
        ]
    }
}
