use async_trait::async_trait;
use chrono::Local;
use tracing::log::warn;

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
                for image in images {
                    self.review_image(image).await;
                }
            }
            Err(error) => warn!("An error occurred while getting the images:  {error}"),
        }
    }

    async fn review_image(&self, image: Image) {
        match self
            .image_hoster
            .check_existence(&image.image_hoster_id)
            .await
        {
            Ok(exists) => {
                if !exists {
                    match self.data_access.delete_image(image.id).await {
                        Ok(deleted) => {
                            if !deleted {
                                warn!("The image with the id {} does not exist, but it could not be deleted", image.id);
                                return;
                            }
                        }
                        Err(error) => {
                            warn!("An error occurred while deleting the non-existent image with id {}: {error}", image.id);
                            return;
                        }
                    }
                }
            }
            Err(error) => {
                warn!("An error occurred while checking the image with id {} for its existence: {error}", image.id);
                return;
            }
        }
        if let Err(error) = self.data_access.mark_as_checked(image.id).await {
            warn!(
                "An error occurred while marking the image with id {} as checked: {error}",
                image.id
            );
        }
    }
}
