use async_trait::async_trait;
use chrono::Local;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        api_command::{AuthInfo, Command, CommandError, Result},
        image_hoster::ImageHoster,
        persistent_data::{model::ImageInfo, CommandDataAccess},
    },
    layer::logic::api_command::auth::{authenticator::Authenticator, command_type::CommandType},
    util::{Date, ReportReason, Uuid},
};

const REPORT_FACTOR: f64 = 1.0 / 35.0;

pub struct CommandHandler<DataAccess, Notify, Hoster>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Hoster: ImageHoster,
{
    command_data: DataAccess,
    admin_notification: Notify,
    image_hoster: Hoster,
    auth: Authenticator,
}

impl<DataAccess, Notify, Hoster> CommandHandler<DataAccess, Notify, Hoster>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Hoster: ImageHoster,
{
    /// A function that creates a new [`CommandHandler`]
    ///
    /// # Errors
    /// Returns an error, if the api keys could not be gotten from [`command_data`]
    pub async fn new(
        command_data: DataAccess,
        admin_notification: Notify,
        image_hoster: Hoster,
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
            image_hoster,
            auth: Authenticator::new(keys),
        })
    }

    fn will_be_hidden(image: &ImageInfo) -> bool {
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
impl<DataAccess, Notify, Hoster> Command for CommandHandler<DataAccess, Notify, Hoster>
where
    DataAccess: CommandDataAccess,
    Notify: AdminNotification,
    Hoster: ImageHoster,
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
            }
            let report_info = ImageReportInfo {
                reason,
                image_id,
                image_got_hidden: will_be_hidden,
                image_link: info.image_url,
                report_count: info.report_count,
                positive_rating_count: info.positive_rating_count,
                negative_rating_count: info.negative_rating_count,
                get_image_rank: info.image_rank,
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

    async fn add_image(&self, meal_id: Uuid, image_url: String, auth_info: AuthInfo) -> Result<()> {
        let auth_info = auth_info.ok_or(CommandError::NoAuth)?;
        let command_type = CommandType::AddImage {
            meal_id,
            url: image_url.clone(),
        };
        self.auth.authn_command(&auth_info, &command_type)?;
        let image_meta_data = self.image_hoster.validate_url(&image_url).await?;
        let licence_ok = self.image_hoster.check_licence(&image_meta_data.id).await?;
        if licence_ok {
            self.command_data
                .link_image(
                    meal_id,
                    auth_info.client_id,
                    image_meta_data.id,
                    image_meta_data.image_url,
                )
                .await?;
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
    use crate::interface::api_command::{Command, Result, InnerAuthInfo};
    use crate::layer::logic::api_command::test::mocks::{INVALID_URL, MEAL_ID_TO_FAIL, IMAGE_ID_TO_FAIL};
    use crate::layer::logic::api_command::{
        command_handler::CommandHandler,
        test::mocks::{CommandAdminNotificationMock, CommandDatabaseMock, CommandImageHosterMock},
    };
    use crate::util::Uuid;

    #[tokio::test]
    async fn test_new() {
        assert!(get_handler().await.is_ok());
    }

    #[tokio::test]
    async fn test_report_image() {
        let handler = get_handler().await;
    }

    #[tokio::test]
    async fn test_add_image_upvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "Xz+c2URLRn6rDa58ExTWPXsj3FXnXu/3nPmV62XqypXkQnJTCwI/m9idDRyBqVjqh9ysPKd9tm6JngY/BSYh3Q==".into(),
            client_id: Uuid::default(),
        });
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        
        assert!(handler
            .add_image_upvote(Uuid::default(), None)
            .await
            .is_err()); // No auth information present
        assert!(handler.add_image_upvote(image_id, auth_info.clone()).await.is_ok());
        assert!(handler.add_image_upvote(IMAGE_ID_TO_FAIL, auth_info.clone()).await.is_err());
    }

    #[tokio::test]
    async fn test_add_image_downvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "AQPykbV6530qtbsE93KZsgl0KvORCz5LYH+HhzUSiX1FAFUjo/52y7rnTRq9tlUN3dzRa8xHxWg5y2PwIkItdg==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        });
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        
        assert!(handler
            .add_image_downvote(Uuid::default(), None)
            .await
            .is_err()); // No auth information present
        assert!(handler.add_image_downvote(image_id, auth_info.clone()).await.is_ok());
        assert!(handler.add_image_downvote(IMAGE_ID_TO_FAIL, auth_info.clone()).await.is_err());
    }

    #[tokio::test]
    async fn test_remove_image_upvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "lb4TH+zjHTl0Z9zijEZ7KtOFIBFHvY70rmZtX+Xk/fa++fGJtAS10EjFOqAgx/0scDJDbhpdn9WS5Yy5zCYeoQ==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        });
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        
        assert!(handler
            .remove_image_upvote(Uuid::default(), None)
            .await
            .is_err()); // No auth information present
        assert!(handler.remove_image_upvote(image_id, auth_info.clone()).await.is_ok());
        assert!(handler.remove_image_upvote(IMAGE_ID_TO_FAIL, auth_info.clone()).await.is_err());
    }
    #[tokio::test]
    async fn test_remove_image_downvote() {
        let handler = get_handler().await.unwrap();
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "lb4TH+zjHTl0Z9zijEZ7KtOFIBFHvY70rmZtX+Xk/fa++fGJtAS10EjFOqAgx/0scDJDbhpdn9WS5Yy5zCYeoQ==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        });
        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        
        assert!(handler
            .remove_image_downvote(Uuid::default(), None)
            .await
            .is_err()); // No auth information present
        assert!(handler.remove_image_downvote(image_id, auth_info.clone()).await.is_ok());
        assert!(handler.remove_image_downvote(IMAGE_ID_TO_FAIL, auth_info.clone()).await.is_err());
    }
    #[tokio::test]
    async fn test_add_image() {
        let handler = get_handler().await.unwrap();
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "ozNFvc9F0FWdrkFuncTpWA8z+ugwwox4El21hNiHoJW1conWnAOL0q7g4iNWEdDViFyTBjmDhK17FKpmReAgrA==".into(),
            client_id: Uuid::default(),
        });
        let meal_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        let image_url = "http://test.de";

        assert!(handler.add_image(meal_id, image_url.to_string(), None).await.is_err());
        assert!(handler.add_image(meal_id, image_url.to_string(), auth_info.clone()).await.is_ok());
        assert!(handler.add_image(meal_id, INVALID_URL.to_string(), auth_info.clone()).await.is_err());
        assert!(handler.add_image(MEAL_ID_TO_FAIL, image_url.to_string(), auth_info.clone()).await.is_err());
    }
    #[tokio::test]
    async fn test_set_meal_rating() {
        let handler = get_handler().await.unwrap();        
        let auth_info = Some(InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "rHh8opE3qYEupyehP6ttMLVpgV0lTmGJE4rV53oFUUGCdQkzZnUu2snS/Hr4ZyYZ/1D7WiLonHSldbYSMLVBVQ==".into(),
            client_id: Uuid::default(),
        });
        let meal_id = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();
        assert!(handler.set_meal_rating(meal_id, 0, None).await.is_err());
        assert!(handler.set_meal_rating(meal_id, 2, auth_info.clone()).await.is_ok());
        assert!(handler.set_meal_rating(MEAL_ID_TO_FAIL, 2, auth_info.clone()).await.is_err());
    }

    async fn get_handler() -> Result<
        CommandHandler<CommandDatabaseMock, CommandAdminNotificationMock, CommandImageHosterMock>,
    > {
        let command_data = CommandDatabaseMock::default();
        let admin_notification = CommandAdminNotificationMock::default();
        let image_hoster = CommandImageHosterMock::default();
        CommandHandler::new(command_data, admin_notification, image_hoster).await
    }
}
