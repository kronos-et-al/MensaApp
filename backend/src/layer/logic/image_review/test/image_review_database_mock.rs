use async_trait::async_trait;

use crate::{
    interface::persistent_data::{model::Image, ImageReviewDataAccess, Result},
    util::{Date, Uuid},
};

pub struct ImageReviewDatabaseMock;


#[async_trait]
impl ImageReviewDataAccess for ImageReviewDatabaseMock {
    /// Returns the first n images sorted by rank which are related to an meal served at the given day.
    async fn get_n_images_by_rank_date(&self, n: u32, _date: Date) -> Result<Vec<Image>> {
        let mut images = Vec::new();
        for _i in 0..n {
            images.push(Image {
                id: Uuid::default(),
                image_hoster_id: String::default(),
                url: String::default(),
                rank: 0.0,
                upvotes: 0,
                downvotes: 0,
            });
        }
        Ok(images)
    }
    /// Returns the first n images sorted by rank which are related to an meal served in the next week or which were not validated last week.
    async fn get_n_images_next_week_by_rank_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        let mut images = Vec::new();
        for _i in 0..n {
            images.push(Image {
                id: Uuid::default(),
                image_hoster_id: String::default(),
                url: String::default(),
                rank: 0.0,
                upvotes: 0,
                downvotes: 0,
            });
        }
        Ok(images)
    }
    /// Returns the first n images sorted by the date of the last check (desc) which were not validated in the last week.
    async fn get_n_images_by_last_checked_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        let mut images = Vec::new();
        for _i in 0..n {
            images.push(Image {
                id: Uuid::default(),
                image_hoster_id: String::default(),
                url: String::default(),
                rank: 0.0,
                upvotes: 0,
                downvotes: 0,
            });
        }
        Ok(images)
    }
    /// Removes an image with all relations from the database.
    async fn delete_image(&self, _id: Uuid) -> Result<bool> {
        Ok(true)
    }
    /// Marks all images identified by the given uuids as checked.
    async fn mark_as_checked(&self, _ids: Vec<Uuid>) -> Result<()> {
        Ok(())
    }
}
