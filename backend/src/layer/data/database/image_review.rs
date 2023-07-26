use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{model::Image, ImageReviewDataAccess, Result},
    null_error,
    util::{Date, Uuid},
};

pub struct PersistentImageReviewData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl ImageReviewDataAccess for PersistentImageReviewData {
    async fn get_n_images_by_rank_date(&self, n: u32, date: Date) -> Result<Vec<Image>> {
        sqlx::query!(
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
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_n_images_next_week_by_rank_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        sqlx::query!(
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
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_n_images_by_last_checked_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        sqlx::query!(
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
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn delete_image(&self, id: Uuid) -> Result<()> {
        // Todo on delete cascade?
        sqlx::query!(
            "DELETE FROM image WHERE image_id = $1 RETURNING image_id",
            id
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(())
    }

    async fn mark_as_checked(&self, id: Uuid) -> Result<()> {
        sqlx::query!(
            "UPDATE image SET last_verified_date = CURRENT_DATE WHERE image_id = $1",
            id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }
}
