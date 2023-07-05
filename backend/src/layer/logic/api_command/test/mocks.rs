//! This crate contains mocks of [`CommandDataAccess`] and [`ImageHoster`] and [`AdminNotification`] for testing.

use async_trait::async_trait;

use crate::{
    interface::{persistent_data::{
        model::{ApiKey, ImageInfo},
        CommandDataAccess, Result as DataResult,
    }, image_hoster::{ImageHoster, model::ImageMetaData, Result as ImageResult}, admin_notification::{AdminNotification, ImageReportInfo}},
    util::{ReportReason, Uuid, Date},
};

pub struct CommandDatabaseMock;

#[async_trait]
impl CommandDataAccess for CommandDatabaseMock {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(_image_id: Uuid) -> DataResult<ImageInfo> {
        let info = ImageInfo {
            approved: true,
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
    async fn hide_image(_image_id: Uuid) -> DataResult<()> {
        Ok(())
    }

    /// Saves an image report
    async fn add_report(_image_id: Uuid, _client_id: Uuid, _reason: ReportReason) -> DataResult<()> {
        Ok(())
    }

    /// Adds an upvote to the given image. An user can only down- or upvote an image.
    async fn add_upvote(_image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        Ok(())
    }

    /// Adds a downvote to the given image. An user can only down- or upvote an image.
    async fn add_downvote(_image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        Ok(())
    }

    /// Removes an upvote from the given image.
    async fn remove_upvote(_image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        Ok(())
    }

    /// Removes a downvote from the given image.
    async fn remove_downvote(_image_id: Uuid, _user_id: Uuid) -> DataResult<()> {
        Ok(())
    }

    /// Adds an image link to the database. The image will be related to the given meal.
    async fn link_image(
        _user_id: Uuid,
        _meal_id: Uuid,
        _image_hoster_id: String,
        _url: String,
    ) -> DataResult<()> {
        Ok(())
    }

    /// Adds a rating to the database. The rating will be related to the given meal and the given user.
    async fn add_rating(_meal_id: Uuid, _user_id: Uuid, _rating: u32) -> DataResult<()> {
        Ok(())
    }

    /// Loads all api_keys from the database.
    async fn get_api_keys() -> DataResult<Vec<ApiKey>> {
        let mut keys = Vec::new();
        for i in 2..10 {
            let key = ApiKey {
                key: i.to_string(),
                description: String::from("Hello, World! Nr. ") + &i.to_string(),
            };
            keys.push(key);
        }
        Ok(keys)
    }
}


pub struct CommandImageHosterMock;

#[async_trait]
impl ImageHoster for CommandImageHosterMock {
    /// Checks if the given link is valid and provides additional information (ImageMetaData) from the hoster.
    async fn validate_url(url: String) -> ImageResult<ImageMetaData> {
        let meta_data = ImageMetaData {
            id: String::new(),
            image_url: url,
            licence: String::new(),
        };
        Ok(meta_data)
    }
    /// Checks if an image still exists at the hoster website.
    async fn check_existence(_photo_id: String) -> ImageResult<bool> {
        Ok(true)
    }
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(_photo_id: String) -> ImageResult<bool> {
        Ok(true)
    }
}

pub struct CommandAdminNotificationMock;

#[async_trait]
impl AdminNotification for CommandAdminNotificationMock {
    /// Notifies an administrator about a newly reported image and the response automatically taken.
    async fn notify_admin_image_report(_info: ImageReportInfo) {
        
    }
}