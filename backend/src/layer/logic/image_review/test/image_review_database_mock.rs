use std::sync::{Arc, Mutex};

use async_trait::async_trait;

use crate::{
    interface::persistent_data::{model::Image, ImageReviewDataAccess, Result, DataError},
    util::{Date, Uuid},
};

pub const ID_TO_THROW_ERROR_ON_DELETE: Uuid = Uuid::from_u128(7u128);
pub const ID_TO_FAIL_DELETE: Uuid = Uuid::from_u128(24u128);

#[derive(Default)]
pub struct ImageReviewDatabaseMock {
    n_images_by_rank_date_calls: Arc<Mutex<u32>>,
    n_images_next_week_by_rank_not_checked_last_week_calls: Arc<Mutex<u32>>,
    n_images_by_last_checked_not_checked_last_week_calls: Arc<Mutex<u32>>,
    delete_image_calls: Arc<Mutex<u32>>,
    mark_as_checked_calls: Arc<Mutex<u32>>,
}

impl ImageReviewDatabaseMock {
    #[must_use]
    pub fn get_n_images_by_rank_date_calls(&self) -> u32 {
        *self
            .n_images_by_rank_date_calls
            .lock()
            .expect("failed to lock mutex for `n_images_by_rank_date_calls` counter")
    }
    #[must_use]
    pub fn get_n_images_next_week_by_rank_not_checked_last_week_calls(&self) -> u32 {
        *self.n_images_next_week_by_rank_not_checked_last_week_calls.lock().expect("failed to lock mutex for `n_images_next_week_by_rank_not_checked_last_week_calls` counter")
    }
    #[must_use]
    pub fn get_n_images_by_last_checked_not_checked_last_week_calls(&self) -> u32 {
        *self.n_images_by_last_checked_not_checked_last_week_calls.lock().expect("failed to lock mutex for `n_images_by_last_checked_not_checked_last_week_calls` counter")
    }
    #[must_use]
    pub fn get_delete_image_calls(&self) -> u32 {
        *self
            .delete_image_calls
            .lock()
            .expect("failed to lock mutex for `delete_image_calls` counter")
    }
    #[must_use]
    pub fn get_mark_as_checked_calls(&self) -> u32 {
        *self
            .mark_as_checked_calls
            .lock()
            .expect("failed to lock mutex for `mark_as_checked_calls` counter")
    }
}

#[async_trait]
impl ImageReviewDataAccess for ImageReviewDatabaseMock {
    /// Returns the first n images sorted by rank which are related to an meal served at the given day.
    async fn get_n_images_by_rank_date(&self, n: u32, _date: Date) -> Result<Vec<Image>> {
        *self
            .n_images_by_rank_date_calls
            .lock()
            .expect("failed to lock mutex for `n_images_by_rank_date_calls` counter") += 1;

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
        *self.n_images_next_week_by_rank_not_checked_last_week_calls.lock().expect("failed to lock mutex for `n_images_next_week_by_rank_not_checked_last_week_calls` counter") += 1;

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
        *self.n_images_by_last_checked_not_checked_last_week_calls.lock().expect("failed to lock mutex for `n_images_by_last_checked_not_checked_last_week_calls` counter") += 1;

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
    async fn delete_image(&self, id: Uuid) -> Result<bool> {
        *self
            .delete_image_calls
            .lock()
            .expect("failed to lock mutex for `delete_image_calls` counter") += 1;
        if id == ID_TO_THROW_ERROR_ON_DELETE {
            Err(DataError::NoSuchItem)
        } else if id == ID_TO_FAIL_DELETE {
            Ok(false)
        } else {
            Ok(true)
        }
    }
    /// Marks all images identified by the given uuids as checked.
    async fn mark_as_checked(&self, _id: Uuid) -> Result<()> {
        *self
            .mark_as_checked_calls
            .lock()
            .expect("failed to lock mutex for `mark_as_checked_calls` counter") += 1;

        Ok(())
    }
}
