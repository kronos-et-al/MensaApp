use async_trait::async_trait;
use chrono::Local;

use crate::interface::{
    image_hoster::ImageHoster, image_review::ImageReviewScheduling,
    persistent_data::ImageReviewDataAccess,
};

pub struct ImageReviewer<D, H> where
D: ImageReviewDataAccess,
H: ImageHoster, {
    data_access: D,
    image_hoster: H,
}

impl<D, H> ImageReviewer<D, H>
where
    D: ImageReviewDataAccess,
    H: ImageHoster,
{
    #[must_use]
    const fn new(data_access: D, image_hoster: H) -> Self {
        Self { data_access, image_hoster }
    }
}

#[async_trait]
impl<D, H> ImageReviewScheduling for ImageReviewer<D, H>
where
    D: ImageReviewDataAccess,
    H: ImageHoster,
{
    /// Start the image review process.
    async fn start_image_review(&self) {
        let today = Local::now().date_naive();
        let today_images = self.data_access.get_n_images_by_rank_date(500, today).await.unwrap();
        let week_images = self.data_access.get_n_images_next_week_by_rank_not_checked_last_week(500).await.unwrap();
        let old_images  = self.data_access.get_n_images_by_last_checked_not_checked_last_week(500).await.unwrap();

        todo!();
    }
}
