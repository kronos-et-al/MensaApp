use async_graphql::{ComplexObject, SimpleObject, Result, Context};

use crate::util::Uuid;

use super::line::Line;


#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Canteen {
    id: Uuid,
    name: String,
}

#[ComplexObject]
impl Canteen {
    async fn lines(&self, ctx: &Context<'_>) -> Result<Vec<Line>> {
        todo!()
    }
}