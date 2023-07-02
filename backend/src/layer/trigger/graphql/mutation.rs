use async_graphql::{Context, Object, Result};

use crate::util::{Uuid, ReportReason};

use super::util::ApiUtil;

/// Class implementing `GraphQLs` root mutations.
pub struct MutationRoot;

#[Object]
impl MutationRoot {
    /// This query adds an image to the specified main dish.
    ///
    /// `image_url` is a link to a Flickr image used to get information about it.
    ///
    /// If the meal does not exist, or the URL does not lead to Flickr
    /// or the image is not licenced under a [CC0](https://creativecommons.org/publicdomain/zero/1.0/) licence
    /// or another error occurred while adding the image an error message will be returned.
    ///
    /// If the image was added is successful, `true` is returned.
    async fn add_image(
        &self,
        ctx: &Context<'_>,
        #[graphql(desc = "Id of the meal to link an image to.")] meal_id: Uuid,
        #[graphql(desc = "Flickr url to the image.")] image_url: String,
    ) -> Result<bool> {
        let command = ctx.get_command();
        let auth_info = ctx.get_auth_info();

        command.add_image(meal_id, image_url, auth_info).await?;
        Ok(true)
    }

    async fn set_rating(&self, ctx: &Context<'_>, meal_id: Uuid, rating: u32) -> Result<bool> {
        todo!()
    }

    async fn add_upvote(&self, ctx: &Context<'_>, image_id: Uuid) -> Result<bool> {
        todo!()
    }

    async fn remove_upvote(&self, ctx: &Context<'_>, image_id: Uuid) -> Result<bool> {
        todo!()
    }

    async fn add_downvote(&self, ctx: &Context<'_>, image_id: Uuid) -> Result<bool> {
        todo!()
    }

    async fn remove_downvote(&self, ctx: &Context<'_>, image_id: Uuid) -> Result<bool> {
        todo!()
    }

    async fn report_image(&self, ctx: &Context<'_>, image_id: Uuid, reason: ReportReason) -> Result<bool> {
        todo!()
    }
}
