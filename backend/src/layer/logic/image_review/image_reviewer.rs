use async_trait::async_trait;
use chrono::Local;
use tracing::log::{debug, warn};

use crate::interface::{
    image_hoster::ImageHoster,
    image_review::ImageReviewScheduling,
    persistent_data::{model::Image, ImageReviewDataAccess, Result},
};

const NUMBER_OF_IMAGES_TO_CHECK: u32 = 500;

pub struct ImageReviewer<D, H>
where
    D: ImageReviewDataAccess,
    H: ImageHoster,
{
    data_access: D,
    image_hoster: H,
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
        self.review_images(
            self.data_access
                .get_n_images_by_rank_date(NUMBER_OF_IMAGES_TO_CHECK, today)
                .await,
        )
        .await;
        self.review_images(
            self.data_access
                .get_n_images_next_week_by_rank_not_checked_last_week(NUMBER_OF_IMAGES_TO_CHECK)
                .await,
        )
        .await;
        self.review_images(
            self.data_access
                .get_n_images_by_last_checked_not_checked_last_week(NUMBER_OF_IMAGES_TO_CHECK)
                .await,
        )
        .await;
    }
}

impl<D, H> ImageReviewer<D, H>
where
    D: ImageReviewDataAccess,
    H: ImageHoster,
{
    #[must_use]
    pub const fn new(data_access: D, image_hoster: H) -> Self {
        Self {
            data_access,
            image_hoster,
        }
    }

    async fn review_images(&self, images: Result<Vec<Image>>) {
        match images {
            Ok(images) => {
                debug!("NO HELP!");
                if let Err(error) = self.review_image(&images).await {
                    warn!("HELP! {error}");
                }
            }
            Err(error) => warn!("HELP! {error}"),
        }
    }

    async fn review_image(&self, images: &Vec<Image>) -> Result<()> {
        self.delete_nonexistent_images(images).await?;
        self.mark_as_checked(images).await
    }

    async fn delete_nonexistent_images(&self, images: &Vec<Image>) -> Result<()> {
        for image in images {
            match self
                .image_hoster
                .check_existence(&image.image_hoster_id)
                .await
            {
                Ok(exists) => {
                    if !exists {
                        self.data_access.delete_image(image.id).await?;
                    }
                }
                Err(error) => warn!("HELP! {error}"),
            }
        }
        Ok(())
    }

    async fn mark_as_checked(&self, existing_images: &[Image]) -> Result<()> {
        let ids: Vec<uuid::Uuid> = existing_images.iter().map(|image| image.id).collect();
        self.data_access.mark_as_checked(ids).await
    }
}
