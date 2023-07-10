use async_trait::async_trait;
use chrono::Local;
use std::marker::{Send, Sync};

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        api_command::{AuthInfo, Command, Result},
        image_hoster::ImageHoster,
        persistent_data::CommandDataAccess,
    },
    layer::logic::api_command::auth::{
        authenticator::Authenticator, image_command_type::ImageCommandType,
    },
    util::{Date, ReportReason, Uuid},
};

const REPORT_FACTOR: f64 = 1.0 / 35.0;

pub struct CommandHandler<D, A, I>
where
    D: CommandDataAccess + Sync + Send,
    A: AdminNotification + Sync + Send,
    I: ImageHoster + Sync + Send,
{
    command_data: D,
    admin_notification: A,
    image_hoster: I,
    auth: Authenticator,
}

impl<D, A, I> CommandHandler<D, A, I>
where
    D: CommandDataAccess + Sync + Send,
    A: AdminNotification + Sync + Send,
    I: ImageHoster + Sync + Send,
{
    pub async fn new(command_data: D, admin_notification: A, image_hoster: I) -> Self {
        let keys: Vec<String> = command_data
            .get_api_keys()
            .await
            .expect("HELP!")
            .into_iter()
            .map(|x| x.key)
            .collect();
        Self {
            command_data,
            admin_notification,
            image_hoster,
            auth: Authenticator::new(keys),
        }
    }

    fn get_date_difference(date: Date) -> i64 {
        let today = Local::now().date_naive();
        let difference = today.signed_duration_since(date);
        difference.num_days()
    }

    fn get_report_barrier(date: Date) -> u32 {
        let t: f64 = Self::get_date_difference(date) as f64;
        (REPORT_FACTOR * t * t).floor() as u32 + 5
    }
}

#[async_trait]
impl<D, A, I> Command for CommandHandler<D, A, I>
where
    D: CommandDataAccess + Sync + Send,
    A: AdminNotification + Sync + Send,
    I: ImageHoster + Sync + Send,
{
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(
        &self,
        image_id: Uuid,
        reason: ReportReason,
        auth_info: AuthInfo,
    ) -> Result<()> {
        let image_command_type = ImageCommandType::ReportImage;
        self.auth
            .authn_image_command(&auth_info, image_id, image_command_type)?;
        let info = self.command_data.get_image_info(image_id).await.unwrap();
        if !info.approved {
            self.command_data
                .add_report(image_id, auth_info.client_id, reason)
                .await
                .unwrap();
            let image_got_hidden = Self::get_date_difference(info.upload_date) < 30
                && info.report_count > Self::get_report_barrier(info.upload_date);
            if image_got_hidden {
                self.command_data.hide_image(image_id);
            }
            let report_info = ImageReportInfo {
                reason,
                image_id,
                image_got_hidden,
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

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(&self, image_id: Uuid, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// Command to link an image to a meal.
    async fn add_image(&self, meal_id: Uuid, image_url: String, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(&self, meal_id: Uuid, rating: u32, auth_info: AuthInfo) -> Result<()> {
        todo!()
    }
}
