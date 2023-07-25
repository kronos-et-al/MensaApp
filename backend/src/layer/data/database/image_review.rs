use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{model::Image, ImageReviewDataAccess, Result},
    util::{Date, Uuid},
};

pub struct PersistentImageReviewData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
impl ImageReviewDataAccess for PersistentImageReviewData {
    async fn get_n_images_by_rank_date(&self, n: u32, date: Date) -> Result<Vec<Image>> {
        let images = sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail 
            WHERE food_id in (SELECT food_id from food_plan WHERE serve_date = $1)
            ORDER BY rank DESC
            LIMIT $2
            ",
            date,
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .filter_map(|r| {
            Some(Image {
                id: r.image_id?,
                url: r.url?,
                image_hoster_id: r.hoster_id?,
                downvotes: r.downvotes? as _,
                upvotes: r.upvotes? as _,
                rank: r.rank?,
                approved: r.approved?,
                report_count: r.report_count? as _,
                upload_date: r.link_date?,
            })
        })
        .collect();

        Ok(images)
    }

    async fn get_n_images_next_week_by_rank_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        let images = sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail 
            WHERE food_id in (SELECT food_id from food_plan WHERE serve_date >= CURRENT_DATE AND serve_date < CURRENT_DATE + 7)
            AND last_verified_date < CURRENT_DATE - 7
            ORDER BY rank DESC
            LIMIT $1
            ",
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .filter_map(|r| {
            Some(Image {
                id: r.image_id?,
                url: r.url?,
                image_hoster_id: r.hoster_id?,
                downvotes: r.downvotes? as _,
                upvotes: r.upvotes? as _,
                rank: r.rank?,
                approved: r.approved?,
                report_count: r.report_count? as _,
                upload_date: r.link_date?,
            })
        })
        .collect();

        Ok(images)
    }

    async fn get_n_images_by_last_checked_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        let images = sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail
            WHERE last_verified_date < CURRENT_DATE - 7
            ORDER BY last_verified_date
            LIMIT $1
            ",
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .filter_map(|r| {
            Some(Image {
                id: r.image_id?,
                url: r.url?,
                image_hoster_id: r.hoster_id?,
                downvotes: r.downvotes? as _,
                upvotes: r.upvotes? as _,
                rank: r.rank?,
                approved: r.approved?,
                report_count: r.report_count? as _,
                upload_date: r.link_date?,
            })
        })
        .collect();

        Ok(images)
    }

    async fn delete_image(&self, id: Uuid) -> Result<bool> {
        // Todo on delete cascade?
        let num_deleted = sqlx::query!(
            "DELETE FROM image WHERE image_id = $1 RETURNING image_id",
            id
        )
        .fetch_all(&self.pool)
        .await?
        .len();

        Ok(num_deleted > 0)
    }

    async fn mark_as_checked(&self, ids: Vec<Uuid>) -> Result<()> {
        sqlx::query!(
            "UPDATE image SET last_verified_date = CURRENT_DATE WHERE image_id = ANY ($1)",
            &ids[..]
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }
}
