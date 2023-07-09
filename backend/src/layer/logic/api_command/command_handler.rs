use async_trait::async_trait;

use crate::{
    interface::{
        admin_notification::AdminNotification,
        api_command::{AuthInfo, Command, Result},
        image_hoster::ImageHoster,
        persistent_data::CommandDataAccess,
    },
    layer::logic::api_command::auth::authenticator::Authenticator,
    util::{ReportReason, Uuid},
};

pub struct CommandHandler {
    auth: Authenticator,
}

impl CommandHandler {
    pub async fn new(
        command_data: Box<dyn CommandDataAccess>,
        admin_notification: Box<dyn AdminNotification>,
        image_hoster: Box<dyn ImageHoster>,
    ) -> Self {
        let keys: Vec<String> = command_data
            .get_api_keys()
            .await
            .expect("HELP!")
            .into_iter()
            .map(|x| x.key)
            .collect();
        Self {
            auth: Authenticator::new(keys),
        }
    }
}
#[async_trait]
impl Command for CommandHandler {
    #[doc = " Command to report an image. It als gets checked whether the image shall get hidden."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn report_image<'async_trait>(
        image_id: Uuid,
        reason: ReportReason,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " Command to vote up an image. All down-votes of the same user get removed."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn add_image_upvote<'async_trait>(
        image_id: Uuid,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " Command to vote down an image. All up-votes of the same user get removed."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn add_image_downvote<'async_trait>(
        image_id: Uuid,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " Command to remove an up-vote for an image."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn remove_image_upvote<'async_trait>(
        image_id: Uuid,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " Command to remove an down-vote for an image."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn remove_image_downvote<'async_trait>(
        image_id: Uuid,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " Command to link an image to a meal."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn add_image<'async_trait>(
        meal_id: Uuid,
        image_url: String,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }

    #[doc = " command to add a rating to a meal."]
    #[must_use]
    #[allow(clippy::type_complexity, clippy::type_repetition_in_bounds)]
    fn set_meal_rating<'async_trait>(
        meal_id: Uuid,
        rating: u32,
        auth_info: AuthInfo,
    ) -> ::core::pin::Pin<
        Box<dyn ::core::future::Future<Output = Result<()>> + ::core::marker::Send + 'async_trait>,
    > {
        todo!()
    }
}
