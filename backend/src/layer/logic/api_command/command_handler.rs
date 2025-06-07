//! See [`CommandHandler`].

use async_trait::async_trait;
use chrono::Local;
use tracing::info;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        api_command::{Command, Result},
        image_storage::ImageStorage,
        image_validation::ImageValidation,
        persistent_data::{model::Image, CommandDataAccess},
    },
    util::{image_id_to_url, Date, ReportReason, Uuid},
};

use super::image_preprocessing::{ImagePreprocessingInfo, ImagePreprocessor};

const REPORT_FACTOR: f64 = 1.0 / 35.0;

/// Class responsible for executing api commands.
#[derive(Debug)]
pub struct CommandHandler<DataAccess, Notify, Storage, Validation>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Storage: ImageStorage,
    Validation: ImageValidation,
{
    command_data: DataAccess,
    admin_notification: Notify,
    image_storage: Storage,
    image_validation: Validation,
    image_preprocessor: ImagePreprocessor,
}

impl<DataAccess, Notify, Storage, Validation>
    CommandHandler<DataAccess, Notify, Storage, Validation>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Storage: ImageStorage,
    Validation: ImageValidation,
{
    /// A function that creates a new [`CommandHandler`]
    ///
    /// # Errors
    /// Returns an error, if the api keys could not be gotten from `command_data`
    pub const fn new(
        image_preprocessing_info: ImagePreprocessingInfo,
        command_data: DataAccess,
        admin_notification: Notify,
        image_storage: Storage,
        image_validation: Validation,
    ) -> Result<Self> {
        Ok(Self {
            command_data,
            admin_notification,
            image_storage,
            image_validation,
            image_preprocessor: ImagePreprocessor::new(image_preprocessing_info),
        })
    }

    fn will_be_hidden(image: &Image) -> bool {
        Self::days_since(image.upload_date) <= 30
            && image.report_count >= Self::get_report_barrier(image.upload_date)
    }

    fn days_since(date: Date) -> i64 {
        let today = Local::now().date_naive();
        let difference = today.signed_duration_since(date);
        difference.num_days()
    }

    #[allow(
        clippy::cast_possible_truncation,
        clippy::cast_sign_loss,
        clippy::cast_precision_loss
    )]
    fn get_report_barrier(date: Date) -> u32 {
        let t = Self::days_since(date) as f64;
        REPORT_FACTOR.mul_add(t * t, 5.0).floor() as u32
    }
}

#[async_trait]
impl<DataAccess, Notify, Storage, Image> Command
    for CommandHandler<DataAccess, Notify, Storage, Image>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Storage: ImageStorage,
    Image: ImageValidation,
{
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        client_id: Uuid,
    ) -> Result<()> {
        let mut info = self.command_data.get_image_info(image_id).await?;
        if !info.image.approved {
            info.image.report_count += 1;
            self.command_data
                .add_report(image_id, client_id, reason)
                .await?;
            let will_be_hidden = Self::will_be_hidden(&info.image);
            if will_be_hidden {
                self.command_data.hide_image(image_id).await?;
                info!(image_info = ?info, "Automatically hid image {image_id} because reported {} times.", info.image.report_count);
            }
            let report_info = ImageReportInfo {
                reason,
                image_id,
                image_got_hidden: will_be_hidden,
                image_url: image_id_to_url(image_id),
                report_count: info.image.report_count,
                positive_rating_count: info.image.upvotes,
                negative_rating_count: info.image.downvotes,
                image_rank: info.image.rank,
                report_barrier: Self::get_report_barrier(info.image.upload_date),
                client_id,
                image_age: Self::days_since(info.image.upload_date),
                report_date: Local::now().date_naive(),
                meal_id: info.image.meal_id,
                meal_name: info.meal_name,
                other_image_urls: info.other_image_urls,
                approval_message: info.approval_message,
            };

            self.admin_notification
                .notify_admin_image_report(report_info)
                .await;
        }
        Ok(())
    }

    async fn add_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        self.command_data.add_upvote(image_id, client_id).await?;
        Ok(())
    }

    async fn add_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        self.command_data.add_downvote(image_id, client_id).await?;
        Ok(())
    }

    async fn remove_image_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        self.command_data.remove_upvote(image_id, client_id).await?;
        Ok(())
    }

    async fn remove_image_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<()> {
        self.command_data
            .remove_downvote(image_id, client_id)
            .await?;
        Ok(())
    }

    async fn add_image(
        &self,
        meal_id: Uuid,
        image_type: Option<String>,
        image_file: Vec<u8>,
        client_id: Uuid,
    ) -> Result<()> {
        let image = self
            .image_preprocessor
            .preprocess_image(image_file, image_type)?;

        // verify with api
        let message = self.image_validation.validate_image(&image).await?;

        // link in database
        let image_id = self
            .command_data
            .link_image(meal_id, client_id, message.as_deref())
            .await?;

        // store to disk
        if let Err(e) = self.image_storage.save_image(image_id, image).await {
            self.command_data.revert_link_image(image_id).await?;
            return Err(e.into());
        }

        Ok(())
    }

    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, client_id: Uuid) -> Result<()> {
        self.command_data
            .add_rating(meal_id, client_id, rating)
            .await?;
        Ok(())
    }

    async fn delete_image(&self, image_id: Uuid) -> Result<()> {
        self.command_data.delete_image(image_id).await?;
        self.image_storage.delete_image(image_id).await?;
        self.admin_notification
            .notify_admin_image_deleted(image_id)
            .await?;
        Ok(())
    }

    async fn verify_image(&self, image_id: Uuid) -> Result<()> {
        self.command_data.verify_image(image_id).await?;
        self.admin_notification
            .notify_admin_image_verified(image_id)
            .await?;
        Ok(())
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use std::sync::Arc;

    use chrono::Local;

    use crate::interface::api_command::{Command, Result};
    use crate::interface::persistent_data::model::Image;
    use crate::layer::logic::api_command::mocks::{
        CommandImageStorageMock, CommandImageValidationMock, IMAGE_ID_TO_FAIL, MEAL_ID_TO_FAIL,
    };
    use crate::layer::logic::api_command::{
        command_handler::CommandHandler,
        mocks::{CommandAdminNotificationMock, CommandDatabaseMock},
    };
    use crate::util::{ReportReason, Uuid};

    use super::ImagePreprocessingInfo;

    #[tokio::test]
    async fn test_new() {
        assert!(get_handler().is_ok());
    }

    #[tokio::test]
    async fn test_report_image() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::try_from("b637365e-9ec5-47cf-8e39-eab3e10de4e5").unwrap();
        let image_id = Uuid::try_from("afa781ab-278f-441a-9241-f70e1013ed42").unwrap();
        let reason = ReportReason::Advert;
        assert!(handler
            .report_image(image_id, reason, client_id)
            .await
            .is_ok());

        assert!(handler
            .report_image(IMAGE_ID_TO_FAIL, reason, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image_upvote() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap();
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler.add_image_upvote(image_id, client_id).await.is_ok());

        assert!(handler
            .add_image_upvote(IMAGE_ID_TO_FAIL, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image_downvote() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::default();
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler
            .add_image_downvote(image_id, client_id)
            .await
            .is_ok());

        assert!(handler
            .add_image_downvote(IMAGE_ID_TO_FAIL, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_remove_image_upvote() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap();
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler
            .remove_image_upvote(image_id, client_id)
            .await
            .is_ok());

        assert!(handler
            .remove_image_upvote(IMAGE_ID_TO_FAIL, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_remove_image_downvote() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap();
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler
            .remove_image_downvote(image_id, client_id)
            .await
            .is_ok());

        assert!(handler
            .remove_image_downvote(IMAGE_ID_TO_FAIL, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::default();

        let meal_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        // jpg

        let image_file = include_bytes!("tests/test.jpg").to_vec();

        assert!(
            handler
                .add_image(meal_id, Some("image/jpeg".into()), image_file, client_id,)
                .await
                .is_ok(),
            "jpg"
        );

        // wrong format
        let image_file = include_bytes!("tests/test.jpg").to_vec();

        assert!(handler
            .add_image(meal_id, Some("image/png".into()), image_file, client_id,)
            .await
            .is_err());

        // When no format is given, the command may or may not work.
        // let image_file = include_bytes!("tests/b64_test.jpg").to_vec();
        // assert!(handler
        //     .add_image(meal_id, None, image_file, auth_info)
        //     .await
        //     .is_ok());

        // jpg large

        let image_file = include_bytes!("tests/test_large.jpg").to_vec();

        assert!(
            handler
                .add_image(meal_id, Some("image/jpeg".into()), image_file, client_id,)
                .await
                .is_ok(),
            "jpg large"
        );

        // png
        let image_file = include_bytes!("tests/test.png").to_vec();

        assert!(
            handler
                .add_image(meal_id, Some("image/png".into()), image_file, client_id,)
                .await
                .is_ok(),
            "png"
        );

        // tiff
        let image_file = include_bytes!("tests/test.tif").to_vec();

        assert!(
            handler
                .add_image(meal_id, Some("image/tiff".into()), image_file, client_id,)
                .await
                .is_ok(),
            "tiff"
        );
    }

    #[tokio::test]
    async fn test_set_meal_rating() {
        let handler = get_handler().unwrap();
        let client_id = Uuid::default();
        let meal_id = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();
        assert!(handler.set_meal_rating(meal_id, 2, client_id).await.is_ok());

        assert!(handler
            .set_meal_rating(MEAL_ID_TO_FAIL, 2, client_id)
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_delete_image() {
        let handler = get_handler().unwrap();

        let image = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();

        handler.delete_image(image).await.unwrap();
    }

    #[tokio::test]
    async fn test_verify_image() {
        let handler = get_handler().unwrap();

        let image = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();

        handler.verify_image(image).await.unwrap();
    }

    #[tokio::test]
    async fn test_arc() {
        let handler = get_handler().unwrap();
        let handler = Arc::new(handler);

        let id = Uuid::default();
        let image_file = include_bytes!("tests/test.jpg").to_vec();

        handler.add_image(id, None, image_file, id).await.unwrap();
        handler.add_image_downvote(id, id).await.unwrap();
        handler.add_image_upvote(id, id).await.unwrap();
        handler.remove_image_downvote(id, id).await.unwrap();
        handler.remove_image_upvote(id, id).await.unwrap();
        handler
            .report_image(id, ReportReason::Advert, id)
            .await
            .unwrap();
        handler.set_meal_rating(id, 1, id).await.unwrap();
        handler.verify_image(id).await.unwrap();
        handler.delete_image(id).await.unwrap();
    }

    const fn get_handler() -> Result<
        CommandHandler<
            CommandDatabaseMock,
            CommandAdminNotificationMock,
            CommandImageStorageMock,
            CommandImageValidationMock,
        >,
    > {
        let command_data = CommandDatabaseMock;
        let admin_notification = CommandAdminNotificationMock;
        let image_storage = CommandImageStorageMock;
        let image_validation = CommandImageValidationMock;
        let info = ImagePreprocessingInfo {
            max_image_height: 1000,
            max_image_width: 1000,
        };

        CommandHandler::new(
            info,
            command_data,
            admin_notification,
            image_storage,
            image_validation,
        )
    }

    #[test]
    fn test_will_be_hidden() {
        let image = Image {
            upload_date: Local::now().date_naive(),
            report_count: 10,
            ..Default::default()
        };
        assert!(CommandHandler::<
            CommandDatabaseMock,
            CommandAdminNotificationMock,
            CommandImageStorageMock,
            CommandImageValidationMock,
        >::will_be_hidden(&image));
    }
}
