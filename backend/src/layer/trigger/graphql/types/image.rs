use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{
    interface::persistent_data::model, layer::trigger::graphql::util::ApiUtil, util::Uuid,
};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Image {
    id: Uuid,
    url: String,
    rank: f32,
    upvotes: u32,
    downvotes: u32,
}

#[ComplexObject]
impl Image {
    async fn personal_upvote(&self, ctx: &Context<'_>) -> Result<bool> {
        let data = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
        let upvote = data.get_personal_upvote(self.id, client_id).await?;
        Ok(upvote)
    }
    async fn personal_downvote(&self, ctx: &Context<'_>) -> Result<bool> {
        let data = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
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
            url: value.url,
            rank: value.rank,
        }
    }
}
