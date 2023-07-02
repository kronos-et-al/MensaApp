use async_graphql::{ComplexObject, SimpleObject, Result, Context};

use crate::util::{Uuid, Date};

use super::{canteen::Canteen, meal::Meal};


#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Line {
    id: Uuid,
    name: String,
}

#[ComplexObject]
impl Line {
    async fn canteen(&self, ctx: &Context<'_>) -> Result<Canteen> {
        todo!()
    }

    async fn meals(&self, ctx: &Context<'_>, date: Date) -> Result<Vec<Meal>> {
        todo!()
    }
}