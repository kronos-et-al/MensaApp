use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::{instrument};
use crate::{
    interface::persistent_data::model, layer::trigger::graphql::util::ApiUtil, util::Uuid,
};
use crate::layer::trigger::graphql::util::trace_query_request;

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
pub struct Image {
    /// The id of the image
    id: Uuid,
    /// The url of the image
    url: String,
    /// The rank of the image. Used for determining the order of images to be shown.
    rank: f32,
    /// The amount of users, who upvoted the image
    upvotes: u32,
    /// The amount of users, who downvoted the image
    downvotes: u32,
}

#[ComplexObject]
impl Image {
    /// A function for determining whether or not the user upvoted the image
    #[instrument(skip(ctx))]
    async fn personal_upvote(&self, ctx: &Context<'_>) -> Result<bool> {
        trace_query_request();
        let data = ctx.get_data_access();
        let client_id = match ctx.get_auth_info() {
            Some(info) => info.client_id,
            None => return Ok(false),
        };
        let upvote = data.get_personal_upvote(self.id, client_id).await?;
        Ok(upvote)
    }
    /// A function for determining whether or not the user downvoted the image
    #[instrument(skip(ctx))]
    async fn personal_downvote(&self, ctx: &Context<'_>) -> Result<bool> {
        trace_query_request();
        let data = ctx.get_data_access();
        let client_id = match ctx.get_auth_info() {
            Some(info) => info.client_id,
            None => return Ok(false),
        };
        let downvote = data.get_personal_downvote(self.id, client_id).await?;
        Ok(downvote)
    }
}

impl From<model::Image> for Image {
    /// A function for converting Images from `persistent_data/model/image` to types/image 
    fn from(value: model::Image) -> Self {
        Self {
            id: value.id,
            downvotes: value.downvotes,
            upvotes: value.upvotes,
            url: value.url,
            rank: value.rank,
        }
    }
}
