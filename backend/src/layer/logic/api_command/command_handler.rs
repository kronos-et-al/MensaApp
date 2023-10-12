//! See [`CommandHandler`].

use async_trait::async_trait;
use chrono::Local;
use tokio::fs::File;
use tracing::info;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        api_command::{AuthInfo, Command, CommandError, Result},
        image_storage::ImageStorage,
        image_validation::ImageValidation,
        persistent_data::{model::Image, CommandDataAccess},
    },
    layer::logic::api_command::auth::{authenticator::Authenticator, command_type::CommandType},
    util::{image_id_to_url, Date, ReportReason, Uuid},
};

use super::image_preprocessing::ImagePreprocessor;

const REPORT_FACTOR: f64 = 1.0 / 35.0;

/// Structure containing all information necessary for image preprocessing.
#[derive(Debug, Clone, Copy)]
pub struct ImagePreprocessingInfo {
    /// Maximal width of images stored. Images get resized otherwise.
    pub max_image_width: u32,
    /// Maximal height of images stored. Images get resized otherwise.
    pub max_image_height: u32,
}

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
    auth: Authenticator,
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
    pub async fn new(
        image_preprocessing_info: ImagePreprocessingInfo,
        command_data: DataAccess,
        admin_notification: Notify,
        image_storage: Storage,
        image_validation: Validation,
    ) -> Result<Self> {
        let keys: Vec<String> = command_data
            .get_api_keys()
            .await?
            .into_iter()
            .map(|x| x.key)
            .collect();
        Ok(Self {
            command_data,
            admin_notification,
            image_storage,
            image_validation,
            auth: Authenticator::new(keys),
            image_preprocessor: ImagePreprocessor::new(image_preprocessing_info),
        })
    }

    fn will_be_hidden(image: &Image) -> bool {
        Self::days_since(image.upload_date) <= 30
            && image.report_count > Self::get_report_barrier(image.upload_date)
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
        auth_info: AuthInfo,
    ) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;

        let command_type = CommandType::ReportImage { image_id, reason };
        self.auth.authn_command(&auth_info, &command_type)?;
        let mut info = self.command_data.get_image_info(image_id).await?;
        if !info.approved {
            info.report_count += 1;
            self.command_data
                .add_report(image_id, auth_info.client_id, reason)
                .await?;
            let will_be_hidden = Self::will_be_hidden(&info);
            if will_be_hidden {
                self.command_data.hide_image(image_id).await?;
                info!(image = ?info, "Automatically hid image {image_id} because reported {} times.", info.report_count);
            }
            let report_info = ImageReportInfo {
                reason,
                image_id,
                image_got_hidden: will_be_hidden,
                image_link: image_id_to_url(image_id),
                report_count: info.report_count,
                positive_rating_count: info.upvotes,
                negative_rating_count: info.downvotes,
                get_image_rank: info.rank,
                report_barrier: Self::get_report_barrier(info.upload_date),
                client_id: auth_info.client_id,
                image_age: Self::days_since(info.upload_date),
            };

            self.admin_notification
                .notify_admin_image_report(report_info)
                .await;
        }
        Ok(())
    }

    async fn add_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::AddUpvote { image_id };
        self.auth.authn_command(&auth_info, &command_type)?;
        self.command_data
            .add_upvote(image_id, auth_info.client_id)
            .await?;
        Ok(())
    }

    async fn add_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::AddDownvote { image_id };
        self.auth.authn_command(&auth_info, &command_type)?;
        self.command_data
            .add_downvote(image_id, auth_info.client_id)
            .await?;
        Ok(())
    }

    async fn remove_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::RemoveUpvote { image_id };
        self.auth.authn_command(&auth_info, &command_type)?;
        self.command_data
            .remove_upvote(image_id, auth_info.client_id)
            .await?;
        Ok(())
    }

    async fn remove_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::RemoveDownvote { image_id };
        self.auth.authn_command(&auth_info, &command_type)?;
        self.command_data
            .remove_downvote(image_id, auth_info.client_id)
            .await?;
        Ok(())
    }

    async fn add_image(
        &self,
        meal_id: Uuid,
        image_type: Option<String>,
        image_file: File,
        auth_info: AuthInfo,
    ) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        // todo auth
        // let command_type = CommandType::AddImage {
        //     meal_id,
        //     url: image_url,
        // };
        // self.auth.authn_command(&auth_info, &command_type)?;

        let image = self
            .image_preprocessor
            .preprocess_image(image_file, image_type)
            .await?;

        // verify with api
        self.image_validation.validate_image(&image).await?;

        // link in database
        let image_id = self
            .command_data
            .link_image(meal_id, auth_info.client_id)
            .await?;

        // store to disk
        if let Err(e) = self.image_storage.save_image(image_id, image).await {
            self.command_data.revert_link_image(image_id).await?;
            return Err(e.into());
        }

        Ok(())
    }

    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::SetRating { meal_id, rating };
        self.auth.authn_command(&auth_info, &command_type)?;
        self.command_data
            .add_rating(meal_id, auth_info.client_id, rating)
            .await?;
        Ok(())
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use chrono::Local;

    use crate::interface::api_command::{Command, InnerAuthInfo, Result};
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
        assert!(get_handler().await.is_ok());
    }

    #[tokio::test]
    async fn test_report_image() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "zsqn7BQuQZDKhEs2kgjKRA5sAFStu6P+WnF8bEtmU6VVZ7SZn6FB8cUFadoT6s7j9y1MqYMMb3DPctimykn+mg==".into(),
            client_id: Uuid::try_from("b637365e-9ec5-47cf-8e39-eab3e10de4e5").unwrap(),
        };
        let image_id = Uuid::try_from("afa781ab-278f-441a-9241-f70e1013ed42").unwrap();
        let reason = ReportReason::Advert;
        assert!(handler.report_image(image_id, reason, None).await.is_err());
        assert!(handler
            .report_image(image_id, reason, Some(auth_info.clone()))
            .await
            .is_ok());
        let auth_info = InnerAuthInfo {
            hash: "x2D2nVGg9oCyt44TB/pA5LACvo5ZghPVJDMNCfAZOiME8hS1CF4NKaFK3chfbwVEnmZxlVRfmWK2nGHE7yBknQ==".into(),
            ..auth_info
        };
        assert!(handler
            .report_image(IMAGE_ID_TO_FAIL, reason, Some(auth_info.clone()))
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image_upvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "AQPykbV6530qtbsE93KZsgl0KvORCz5LYH+HhzUSiX1FAFUjo/52y7rnTRq9tlUN3dzRa8xHxWg5y2PwIkItdg==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler.add_image_upvote(image_id, None).await.is_err()); // No auth information present
        assert!(handler
            .add_image_upvote(image_id, Some(auth_info.clone()))
            .await
            .is_ok());
        let auth_info = InnerAuthInfo {
            hash: "nNfedG2cgeaOutiLzHSUDbYWRS0tDVwK482ULfqDkV0h/nZl6ZN5bwesenmr+CZBJrc2MT1Ps/I+5sKDy2qdCw==".into(),
            ..auth_info
        };
        assert!(handler
            .add_image_upvote(IMAGE_ID_TO_FAIL, Some(auth_info.clone()))
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image_downvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "Xz+c2URLRn6rDa58ExTWPXsj3FXnXu/3nPmV62XqypXkQnJTCwI/m9idDRyBqVjqh9ysPKd9tm6JngY/BSYh3Q==".into(),
            client_id: Uuid::default(),
        };
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler.add_image_downvote(image_id, None).await.is_err()); // No auth information present
        assert!(handler
            .add_image_downvote(image_id, Some(auth_info.clone()))
            .await
            .is_ok());

        let auth_info = InnerAuthInfo {
                hash: "jFEnp7ky0dbUrisVR5Rh6GOAywS1GGePT6TBbuIumbPjoRHkOgO1vW9iJPc64evEX6YuvdNZTpu4JET2bYxJdw==".into(),
                ..auth_info
            };
        assert!(handler
            .add_image_downvote(IMAGE_ID_TO_FAIL, Some(auth_info.clone()))
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_remove_image_upvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "8jYXv/+3YqO9j9zJnrkSGy4Bx1VZLgXoW95RodDWZ/PmzcAqqhyKiv2gI09JCBUuBOZoDMkNPhCjbesBkCGaxg==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler.remove_image_upvote(image_id, None).await.is_err()); // No auth information present

        assert!(handler
            .remove_image_upvote(image_id, Some(auth_info.clone()))
            .await
            .is_ok());
        let auth_info = InnerAuthInfo {
            hash: "75irLLawyqHZ6RyENq6LgVH91qViG8K9p30xefHUygKYBTkHeAAxMX7zfvmil4FuIr1FcKhFcO7YnubS6JhBrA==".into(),
            ..auth_info
        };
        assert!(handler
            .remove_image_upvote(IMAGE_ID_TO_FAIL, Some(auth_info.clone()))
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_remove_image_downvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "lb4TH+zjHTl0Z9zijEZ7KtOFIBFHvY70rmZtX+Xk/fa++fGJtAS10EjFOqAgx/0scDJDbhpdn9WS5Yy5zCYeoQ==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        assert!(handler.remove_image_downvote(image_id, None).await.is_err()); // No auth information present
        assert!(handler
            .remove_image_downvote(image_id, Some(auth_info.clone()))
            .await
            .is_ok());

        let auth_info = InnerAuthInfo {
                hash: "Jv4OClK/9hYeTQPdInfwjoNtUmVmoLp4+q7LEI5gKhDJLdeaEX+cER7BvFU5JTuzQhG7T8sae55fgYF+ybK7cQ==".into(),
                ..auth_info
            };
        assert!(handler
            .remove_image_downvote(IMAGE_ID_TO_FAIL, Some(auth_info.clone()))
            .await
            .is_err());
    }

    #[tokio::test]
    async fn test_add_image() {
        let handler = get_handler().await.unwrap();
        // todo auth
        let auth_info = Some(InnerAuthInfo {
            api_ident: String::new(),
            hash: String::new(),
            client_id: Uuid::default(),
        });

        let meal_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();

        let dir = tempfile::tempdir().expect("tempdir should be accessible");

        // jpg
        let mut jpg_path = dir.path().to_path_buf();
        jpg_path.push("test.jpg");
        tokio::fs::write(&jpg_path, include_bytes!("tests/test.jpg"))
            .await
            .expect("image should be saved");

        let image_file = tokio::fs::File::open(&jpg_path)
            .await
            .expect("saved file should be opened");

        assert!(
            handler
                .add_image(
                    meal_id,
                    Some("image/jpeg".into()),
                    image_file.try_clone().await.unwrap(),
                    auth_info.clone(),
                )
                .await
                .is_ok(),
            "jpg"
        );

        // When no format is given, the command may or may not work.
        // assert!(handler
        //     .add_image(meal_id, None, image_file, auth_info)
        //     .await
        //     .is_ok());

        // jpg large
        let mut jpg_path = dir.path().to_path_buf();
        jpg_path.push("test_large.jpg");
        tokio::fs::write(&jpg_path, include_bytes!("tests/test_large.jpg"))
            .await
            .expect("image should be saved");

        let image_file = tokio::fs::File::open(&jpg_path)
            .await
            .expect("saved file should be opened");

        assert!(
            handler
                .add_image(
                    meal_id,
                    Some("image/jpeg".into()),
                    image_file.try_clone().await.unwrap(),
                    auth_info.clone(),
                )
                .await
                .is_ok(),
            "jpg large"
        );

        // png
        let mut png_path = dir.path().to_path_buf();
        png_path.push("test.png");
        tokio::fs::write(&png_path, include_bytes!("tests/test.png"))
            .await
            .expect("image should be saved");

        let image_file = tokio::fs::File::open(&png_path)
            .await
            .expect("saved file should be opened");

        assert!(
            handler
                .add_image(
                    meal_id,
                    Some("image/png".into()),
                    image_file.try_clone().await.unwrap(),
                    auth_info.clone(),
                )
                .await
                .is_ok(),
            "png"
        );

        // tiff
        let mut tiff_path = dir.path().to_path_buf();
        tiff_path.push("test.tif");
        tokio::fs::write(&tiff_path, include_bytes!("tests/test.tif"))
            .await
            .expect("image should be saved");

        let image_file = tokio::fs::File::open(&tiff_path)
            .await
            .expect("saved file should be opened");

        assert!(
            handler
                .add_image(
                    meal_id,
                    Some("image/tiff".into()),
                    image_file.try_clone().await.unwrap(),
                    auth_info.clone(),
                )
                .await
                .is_ok(),
            "tiff"
        );

        // todo more cases when saving fails etc?
    }

    #[tokio::test]
    async fn test_set_meal_rating() {
        let handler = get_handler().await.unwrap();
        let auth_info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "rHh8opE3qYEupyehP6ttMLVpgV0lTmGJE4rV53oFUUGCdQkzZnUu2snS/Hr4ZyYZ/1D7WiLonHSldbYSMLVBVQ==".into(),
            client_id: Uuid::default(),
        };
        let meal_id = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();
        assert!(handler.set_meal_rating(meal_id, 0, None).await.is_err());
        assert!(handler
            .set_meal_rating(meal_id, 2, Some(auth_info.clone()))
            .await
            .is_ok());

        let auth_info = InnerAuthInfo {
            hash: "0gdAkgRigzK+vV4IkP20QdUBZPco1E8zQC01F8WiPNO5BMEyKd+W/PiC7abF68B/s8wRW1MgY/7VdscEaKBQDA==".into(),
            ..auth_info
        };
        assert!(handler
            .set_meal_rating(MEAL_ID_TO_FAIL, 2, Some(auth_info.clone()))
            .await
            .is_err());
    }

    async fn get_handler() -> Result<
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
        .await
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
