//! This crate contains mocks of [`CommandDataAccess`] for testing.

use async_trait::async_trait;

use crate::{
    interface::persistent_data::{
        model::{ApiKey, ImageInfo},
        CommandDataAccess, Result,
    },
    util::{ReportReason, Uuid, Date},
};

pub struct CommandDatabaseMock;

#[async_trait]
impl CommandDataAccess for CommandDatabaseMock {
    #[doc = " Returns the ImageInfo struct of image."]
    async fn get_image_info(_image_id: Uuid) -> Result<ImageInfo> {
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

    #[doc = " Marks an image as hidden. Hidden images cant be seen by users."]
    async fn hide_image(_image_id: Uuid) -> Result<()> {
        Ok(())
    }

    #[doc = " Saves an image report"]
    async fn add_report(_image_id: Uuid, _client_id: Uuid, _reason: ReportReason) -> Result<()> {
        Ok(())
    }

    #[doc = " Adds an upvote to the given image. An user can only down- or upvote an image."]
    async fn add_upvote(_image_id: Uuid, _user_id: Uuid) -> Result<()> {
        Ok(())
    }

    #[doc = " Adds a downvote to the given image. An user can only down- or upvote an image."]
    async fn add_downvote(_image_id: Uuid, _user_id: Uuid) -> Result<()> {
        Ok(())
    }

    #[doc = " Removes an upvote from the given image."]
    async fn remove_upvote(_image_id: Uuid, _user_id: Uuid) -> Result<()> {
        Ok(())
    }

    #[doc = " Removes a downvote from the given image."]
    async fn remove_downvote(_image_id: Uuid, _user_id: Uuid) -> Result<()> {
        Ok(())
    }

    #[doc = " Adds an image link to the database. The image will be related to the given meal."]
    async fn link_image(
        _user_id: Uuid,
        _meal_id: Uuid,
        _image_hoster_id: String,
        _url: String,
    ) -> Result<()> {
        Ok(())
    }

    #[doc = " Adds a rating to the database. The rating will be related to the given meal and the given user."]
    async fn add_rating(_meal_id: Uuid, _user_id: Uuid, _rating: u32) -> Result<()> {
        Ok(())
    }

    #[doc = " Loads all api_keys from the database."]
    async fn get_api_keys() -> Result<Vec<ApiKey>> {
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
