//! This crate contains mocks of [`CommandDataAccess`], [`ImageStorage`], [`ImageValidation`] and [`AdminNotification`] for testing.
#![allow(missing_docs)]

use async_trait::async_trait;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        image_validation::ImageValidation,
        image_storage::ImageStorage,
        persistent_data::{
            model::{ApiKey, Image},
            CommandDataAccess, DataError, Result as DataResult,
        },
    },
    util::{Date, ImageResource, ReportReason, Uuid},
};

pub const IMAGE_ID_TO_FAIL: Uuid = Uuid::from_u128(7u128);
pub const MEAL_ID_TO_FAIL: Uuid = Uuid::from_u128(27u128);
pub const INVALID_URL: &str = "hello";

#[derive(Default, Debug)]
pub struct CommandDatabaseMock;

#[async_trait]
impl CommandDataAccess for CommandDatabaseMock {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(&self, _image_id: Uuid) -> DataResult<Image> {
        let info = Image {
            approved: false,
            upload_date: Date::default(),
            report_count: 100,
            url: String::new(),
            upvotes: 200,
            downvotes: 2000,
            rank: 0.1,
            id: Uuid::default(),
            image_hoster_id: String::new(),
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
        meal_id: Uuid,
        _user_id: Uuid,
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

#[derive(Default, Debug)]
pub struct CommandAdminNotificationMock;

#[async_trait]
impl AdminNotification for CommandAdminNotificationMock {
    /// Notifies an administrator about a newly reported image and the response automatically taken.
    async fn notify_admin_image_report(&self, _info: ImageReportInfo) {}
}

#[derive(Default, Debug)]
pub struct CommandImageValidationMock;

#[async_trait]
impl ImageValidation for CommandImageValidationMock {
    async fn validate_image(
        &self,
        _image: &ImageResource,
    ) -> crate::interface::image_validation::Result<()> {
        Ok(())
    }
}

#[derive(Default, Debug)]
pub struct CommandImageStorageMock;

#[async_trait]
impl ImageStorage for CommandImageStorageMock {
    async fn save_image(
        &self,
        _id: Uuid,
        _image: ImageResource,
    ) -> crate::interface::image_storage::Result<()> {
        Ok(())
    }
}
