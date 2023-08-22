use async_trait::async_trait;
use chrono::Local;
use futures::future::join_all;
use thiserror::Error;
use tracing::{warn, error};

use crate::interface::{
    image_hoster::{ImageHoster, ImageHosterError},
    image_review::ImageReviewScheduling,
    persistent_data::{model::Image, DataError, ImageReviewDataAccess},
};

pub type ReviewerResult<T> = std::result::Result<T, ReviewerError>;

/// Enum describing the possible ways, the image review can fail.
#[derive(Debug, Error)]
pub enum ReviewerError {
    #[error("an error occurred while handling an image: {0}")]
    ImageHandlingError(#[from] DataError),
    #[error("an error occurred while checking an image for its existence: {0}")]
    CheckError(#[from] ImageHosterError),
}

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
        if let Err(error) = self.try_start_image_review().await {
            error!("Error reviewing images: {error}");
        }
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

    async fn try_start_image_review(&self) -> ReviewerResult<()> {
        let today = Local::now().date_naive();

        let images_by_rank_date = self
            .data_access
            .get_images_for_date(NUMBER_OF_IMAGES_TO_CHECK, today)
            .await?;
        self.review_images(images_by_rank_date).await;

        let images_next_week_by_rank_not_checked_last_week = self
            .data_access
            .get_unvalidated_images_for_next_week(NUMBER_OF_IMAGES_TO_CHECK)
            .await?;
        self.review_images(images_next_week_by_rank_not_checked_last_week)
            .await;

        let images_by_last_checked_not_checked_last_week = self
            .data_access
            .get_old_images(NUMBER_OF_IMAGES_TO_CHECK)
            .await?;
        self.review_images(images_by_last_checked_not_checked_last_week)
            .await;
        Ok(())
    }

    async fn review_images(&self, images: Vec<Image>) {
        let images = join_all(images.into_iter().map(|image| self.review_image(image))).await;
        images
            .into_iter()
            .filter_map(std::result::Result::err)
            .for_each(|error| warn!("Error reviewing image: {error}"));
    }

    async fn review_image(&self, image: Image) -> ReviewerResult<()> {
        let exists = self
            .image_hoster
            .check_existence(&image.image_hoster_id)
            .await?;
        if exists {
            self.data_access.mark_as_checked(image.id).await?;
        } else {
            self.data_access.delete_image(image.id).await?;
        }
        Ok(())
    }
}

#[cfg(test)]
mod test {
    use tracing_test::traced_test;

    use crate::{
        interface::{image_review::ImageReviewScheduling, persistent_data::model::Image},
        layer::logic::image_review::{
            image_reviewer::ImageReviewer,
            test::{
                image_hoster_mock::{
                    ImageHosterMock, IMAGE_ID_THAT_DOES_NOT_EXIST, IMAGE_ID_TO_FAIL_CHECK_EXISTENCE,
                },
                image_review_database_mock::{
                    ImageReviewDatabaseMock, ID_TO_THROW_ERROR_ON_DELETE,
                },
            },
        },
        util::{Date, Uuid},
    };

    #[tokio::test]
    #[traced_test]
    async fn test_start_image_review() {
        let image_reviewer = ImageReviewer::new(
            ImageReviewDatabaseMock::default(),
            ImageHosterMock::default(),
        );
        image_reviewer.start_image_review().await;

        logs_assert(|lines: &[&str]| {
            assert!(lines.is_empty());
            Ok(())
        });
    }

    #[tokio::test]
    async fn test_full_review() {
        let image_reviewer = get_image_reviewer();
        assert!(image_reviewer.try_start_image_review().await.is_ok());
        assert!(image_reviewer.data_access.get_images_for_date_calls() == 1);
        assert!(
            image_reviewer
                .data_access
                .get_unvalidated_images_for_next_week_calls()
                == 1
        );
        assert!(image_reviewer.data_access.get_old_images_calls() == 1);
    }

    #[tokio::test]
    async fn test_review_image_ok() {
        let image_reviewer = get_image_reviewer();
        assert!(image_reviewer
            .review_image(get_default_image())
            .await
            .is_ok());
        check_correct_call_number(&image_reviewer, 1, 0, 1);
    }

    #[tokio::test]
    async fn test_review_image_throws_error_when_checked() {
        let image = Image {
            image_hoster_id: IMAGE_ID_TO_FAIL_CHECK_EXISTENCE.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        assert!(image_reviewer.review_image(image).await.is_err());
        check_correct_call_number(&image_reviewer, 1, 0, 0);
    }

    #[tokio::test]
    async fn test_review_nonexistent_image() {
        let image = Image {
            image_hoster_id: IMAGE_ID_THAT_DOES_NOT_EXIST.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        assert!(image_reviewer.review_image(image).await.is_ok());
        check_correct_call_number(&image_reviewer, 1, 1, 0);
    }

    #[tokio::test]
    async fn test_review_nonexistent_image_delete_error() {
        let image = Image {
            id: ID_TO_THROW_ERROR_ON_DELETE,
            image_hoster_id: IMAGE_ID_THAT_DOES_NOT_EXIST.to_string(),
            ..get_default_image()
        };
        let image_reviewer = get_image_reviewer();
        assert!(image_reviewer.review_image(image).await.is_err());
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
            approved: false,
            upload_date: Date::default(),
            report_count: 0,
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
