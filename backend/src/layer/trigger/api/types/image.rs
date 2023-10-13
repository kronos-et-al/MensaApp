use crate::{
    interface::persistent_data::model,
    layer::trigger::api::util::ApiUtil,
    util::{image_id_to_url, Uuid},
};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::instrument;

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
pub(in super::super) struct Image {
    /// The id of the image.
    id: Uuid,
    /// The url of the image.
    url: String,
    /// The rank of the image. Used for determining the order of images to be shown.
    rank: f32,
    /// The amount of users, who upvoted the image.
    upvotes: u32,
    /// The amount of users, who downvoted the image.
    downvotes: u32,
}

#[ComplexObject]
impl Image {
    /// This attribute specifies whether or not the user upvoted the image.
    /// Therefor a client id must be provided in the authorization header (see https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md).
    #[instrument(skip(ctx))]
    async fn personal_upvote(&self, ctx: &Context<'_>) -> Result<bool> {
        let data = ctx.get_data_access();
        let client_id = ctx.get_client_id()?;
        let upvote = data.get_personal_upvote(self.id, client_id).await?;
        Ok(upvote)
    }
    /// This attribute specifies whether or not the user downvoted the image.
    /// Therefor a client id must be provided in the authorization header (see https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md).
    #[instrument(skip(ctx))]
    async fn personal_downvote(&self, ctx: &Context<'_>) -> Result<bool> {
        let data = ctx.get_data_access();
        let client_id = ctx.get_client_id()?;
        let downvote = data.get_personal_downvote(self.id, client_id).await?;
        Ok(downvote)
    }
}

impl From<model::Image> for Image {
    fn from(value: model::Image) -> Self {
        Self {
            id: value.id,
            downvotes: value.downvotes,
            upvotes: value.upvotes,
            rank: value.rank,
            url: image_id_to_url(value.id),
        }
    }
}
