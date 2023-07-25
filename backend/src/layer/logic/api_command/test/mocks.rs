//! This crate contains mocks of [`CommandDataAccess`] and [`ImageHoster`] and [`AdminNotification`] for testing.

use async_trait::async_trait;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        image_hoster::{
            model::ImageMetaData, ImageHoster, ImageHosterError, Result as ImageResult,
        },
        persistent_data::{
            model::{ApiKey, ImageInfo},
            CommandDataAccess, DataError, Result as DataResult,
        },
    },
    util::{Date, ReportReason, Uuid},
};

pub const IMAGE_ID_TO_FAIL: Uuid = Uuid::from_u128(7u128);
pub const MEAL_ID_TO_FAIL: Uuid = Uuid::from_u128(27u128);
pub const INVALID_URL: &str = "hello";

#[derive(Default)]
pub struct CommandDatabaseMock;

#[async_trait]
impl CommandDataAccess for CommandDatabaseMock {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(&self, _image_id: Uuid) -> DataResult<ImageInfo> {
        let info = ImageInfo {
            approved: false,
            upload_date: Date::default(),
            report_count: 100,
            image_url: String::new(),
            positive_rating_count: 200,
            negative_rating_count: 2000,
            image_rank: 0.1,
        };
        Ok(info)
    }

    /// Marks an image as hidden. Hidden images cant be seen by users.
    async fn hide_image(&self, image_id: Uuid) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Saves an image report
    async fn add_report(
        &self,
        image_id: Uuid,
        _client_id: Uuid,
        _reason: ReportReason,
    ) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Adds an upvote to the given image. An user can only down- or upvote an image.
    async fn add_upvote(&self, image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Adds a downvote to the given image. An user can only down- or upvote an image.
    async fn add_downvote(&self, image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Removes an upvote from the given image.
    async fn remove_upvote(&self, image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Removes a downvote from the given image.
    async fn remove_downvote(&self, image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        if IMAGE_ID_TO_FAIL == image_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Adds an image link to the database. The image will be related to the given meal.
    async fn link_image(
        &self,
        _user_id: Uuid,
        meal_id: Uuid,
        _image_hoster_id: String,
        _url: String,
    ) -> DataResult<()> {
        if MEAL_ID_TO_FAIL == meal_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Adds a rating to the database. The rating will be related to the given meal and the given user.
    async fn add_rating(&self, meal_id: Uuid, _user_id: Uuid, _rating: u32) -> DataResult<()> {
        if MEAL_ID_TO_FAIL == meal_id {
            Err(DataError::NoSuchItem)
        } else {
            Ok(())
        }
    }

    /// Loads all api_keys from the database.
    async fn get_api_keys(&self) -> DataResult<Vec<ApiKey>> {
        Ok(vec![
            ApiKey {
                key: "abc".into(),
                description: String::new(),
            },
            ApiKey {
                key: "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into(),
                description: String::new(),
            },
        ])
    }
}

#[derive(Default)]
pub struct CommandImageHosterMock;

#[async_trait]
impl ImageHoster for CommandImageHosterMock {
    /// Checks if the given link is valid and provides additional information (ImageMetaData) from the hoster.
    async fn validate_url(&self, url: &str) -> ImageResult<ImageMetaData> {
        if url == INVALID_URL {
            Err(ImageHosterError::PhotoNotFound)
        } else {
            Ok(ImageMetaData {
                id: String::new(),
                image_url: url.to_string(),
            })
        }
    }
    /// Checks if an image still exists at the hoster website.
    async fn check_existence(&self, _photo_id: &str) -> ImageResult<bool> {
        Ok(true)
    }
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(&self, _photo_id: &str) -> ImageResult<bool> {
        Ok(true)
    }
}

#[derive(Default)]
pub struct CommandAdminNotificationMock;

#[async_trait]
impl AdminNotification for CommandAdminNotificationMock {
    /// Notifies an administrator about a newly reported image and the response automatically taken.
    async fn notify_admin_image_report(&self, _info: ImageReportInfo) {}
}
