use std::sync::{Arc, Mutex};

use async_trait::async_trait;

use crate::{
    interface::persistent_data::{model::Image, DataError, ImageReviewDataAccess, Result},
    util::{Date, Uuid},
};

pub const ID_TO_THROW_ERROR_ON_DELETE: Uuid = Uuid::from_u128(7u128);

#[derive(Default)]
pub struct ImageReviewDatabaseMock {
    images_for_date_calls: Arc<Mutex<u32>>,
    unvalidated_images_for_next_week_calls: Arc<Mutex<u32>>,
    old_images_calls: Arc<Mutex<u32>>,
    delete_image_calls: Arc<Mutex<u32>>,
    mark_as_checked_calls: Arc<Mutex<u32>>,
}

impl ImageReviewDatabaseMock {
    #[must_use]
    pub fn get_images_for_date_calls(&self) -> u32 {
        *self
            .images_for_date_calls
            .lock()
            .expect("failed to lock mutex for `images_for_date_calls` counter")
    }

    #[must_use]
    pub fn get_unvalidated_images_for_next_week_calls(&self) -> u32 {
        *self
            .unvalidated_images_for_next_week_calls
            .lock()
            .expect("failed to lock mutex for `unvalidated_images_for_next_week_calls` counter")
    }

    #[must_use]
    pub fn get_old_images_calls(&self) -> u32 {
        *self
            .old_images_calls
            .lock()
            .expect("failed to lock mutex for `old_images_calls` counter")
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
    async fn get_images_for_date(&self, n: u32, _date: Date) -> Result<Vec<Image>> {
        *self
            .images_for_date_calls
            .lock()
            .expect("failed to lock mutex for `images_for_date_calls` counter") += 1;

        Ok((0..n).map(|_| Image::default()).collect())
    }

    async fn get_unvalidated_images_for_next_week(&self, n: u32) -> Result<Vec<Image>> {
        *self
            .unvalidated_images_for_next_week_calls
            .lock()
            .expect("failed to lock mutex for `unvalidated_images_for_next_week_calls` counter") +=
            1;

        Ok((0..n).map(|_| Image::default()).collect())
    }

    async fn get_old_images(&self, n: u32) -> Result<Vec<Image>> {
        *self
            .old_images_calls
            .lock()
            .expect("failed to lock mutex for `old_images_calls` counter") += 1;

        Ok((0..n).map(|_| Image::default()).collect())
    }

    async fn delete_image(&self, id: Uuid) -> Result<()> {
        *self
            .delete_image_calls
            .lock()
            .expect("failed to lock mutex for `delete_image_calls` counter") += 1;
        if id == ID_TO_THROW_ERROR_ON_DELETE {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    async fn mark_as_checked(&self, _id: Uuid) -> Result<()> {
        *self
            .mark_as_checked_calls
            .lock()
            .expect("failed to lock mutex for `mark_as_checked_calls` counter") += 1;

        Ok(())
    }
}
