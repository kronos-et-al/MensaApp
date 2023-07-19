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
        todo!()
    }
    async fn get_n_images_next_week_by_rank_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        todo!()
    }
    async fn get_n_images_by_last_checked_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        todo!()
    }
    async fn delete_image(&self, id: Uuid) -> Result<bool> {
        todo!()
    }
    async fn mark_as_checked(&self, ids: Vec<Uuid>) -> Result<()> {
        todo!()
    }
}
