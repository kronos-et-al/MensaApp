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
            Err(error) => warn!("an error occurred while getting the images: {error}"),
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
                            warn!("an error occurred while deleting the non-existent image with id {}: {error}", image.id);
                            return;
                        }
                    }
                }
            }
            Err(error) => {
                warn!("an error occurred while checking the image with id {} for its existence: {error}", image.id);
                return;
            }
        }
        if let Err(error) = self.data_access.mark_as_checked(image.id).await {
            warn!(
                "an error occurred while marking the image with id {} as checked: {error}",
                image.id
            );
        }
    }
}

#[cfg(test)]
mod test {
    use crate::{
        interface::persistent_data::{model::Image, DataError},
        layer::logic::image_review::{
            image_reviewer::ImageReviewer,
            test::{
                image_hoster_mock::{
                    ImageHosterMock, PHOTO_ID_THAT_DOES_NOT_EXIST, PHOTO_ID_TO_FAIL_CHECK_EXISTENCE,
                },
                image_review_database_mock::{
                    ImageReviewDatabaseMock, ID_TO_FAIL_DELETE, ID_TO_THROW_ERROR_ON_DELETE,
                },
            },
        },
        util::Uuid,
    };

    #[tokio::test]
    async fn test_review_images_warning_on_err() {
        let image_reviewer = get_image_reviewer();
        image_reviewer
            .review_images(Err(DataError::NoSuchItem))
            .await;
        check_correct_call_number(&image_reviewer, 0, 0, 0);
    }

    #[tokio::test]
    async fn test_review_image_ok() {
        let image_reviewer = get_image_reviewer();
        image_reviewer.review_image(get_default_image()).await;
        check_correct_call_number(&image_reviewer, 1, 0, 1);
    }

    #[tokio::test]
    async fn test_review_image_throws_error_when_checked() {
        let image = Image {
            image_hoster_id: PHOTO_ID_TO_FAIL_CHECK_EXISTENCE.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        image_reviewer.review_image(image).await;
        check_correct_call_number(&image_reviewer, 1, 0, 0);
    }

    #[tokio::test]
    async fn test_review_nonexistent_image() {
        let image = Image {
            image_hoster_id: PHOTO_ID_THAT_DOES_NOT_EXIST.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        image_reviewer.review_image(image).await;
        check_correct_call_number(&image_reviewer, 1, 1, 1);
    }

    #[tokio::test]
    async fn test_review_nonexistent_image_delete_error() {
        let image = Image {
            id: ID_TO_THROW_ERROR_ON_DELETE,
            image_hoster_id: PHOTO_ID_THAT_DOES_NOT_EXIST.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        image_reviewer.review_image(image).await;
        check_correct_call_number(&image_reviewer, 1, 1, 0);
    }

    #[tokio::test]
    async fn test_review_nonexistent_image_not_deleted() {
        let image = Image {
            id: ID_TO_FAIL_DELETE,
            image_hoster_id: PHOTO_ID_THAT_DOES_NOT_EXIST.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        image_reviewer.review_image(image).await;
        check_correct_call_number(&image_reviewer, 1, 1, 0);
    }

    fn get_default_image() -> Image {
        Image {
            id: Uuid::from_u128(23u128),
            image_hoster_id: "test".to_string(),
            url: "www.test.com".to_string(),
            rank: 0.0,
            upvotes: 0,
            downvotes: 0,
        }
    }

    fn check_correct_call_number(
        image_reviewer: &ImageReviewer<ImageReviewDatabaseMock, ImageHosterMock>,
        exp_existence_calls: u32,
        exp_delete_calls: u32,
        exp_check_calls: u32,
    ) {
        assert!(image_reviewer.image_hoster.get_existence_calls() == exp_existence_calls);
        assert!(image_reviewer.data_access.get_delete_image_calls() == exp_delete_calls);
        assert!(image_reviewer.data_access.get_mark_as_checked_calls() == exp_check_calls);
    }

    fn get_image_reviewer() -> ImageReviewer<ImageReviewDatabaseMock, ImageHosterMock> {
        let image_hoster = ImageHosterMock::default();
        let image_review_database = ImageReviewDatabaseMock::default();
        ImageReviewer::new(image_review_database, image_hoster)
    }
}
