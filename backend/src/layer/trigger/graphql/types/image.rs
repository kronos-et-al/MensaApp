use async_graphql::{ComplexObject, SimpleObject, Result, Context};

use crate::util::Uuid;


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