use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::Uuid, interface::persistent_data::model};


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
        todo!()
    }
    async fn personal_downvote(&self, ctx: &Context<'_>) -> Result<bool> {
        todo!()
    }
}

impl From<model::Image> for Image {
    fn from(value: model::Image) -> Self {
        Self {
            id: value.id,
            downvotes: value.downvotes,
            upvotes: value.upvotes,
            url: value.url,
            rank: value.rank
        }
    }
}