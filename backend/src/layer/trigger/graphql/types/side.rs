use async_graphql::{ComplexObject, SimpleObject, Result, Context};

use crate::util::{Uuid, Allergen, Additive};


#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Side {
    id: Uuid,
    name: String,
}

#[ComplexObject]
impl Side {
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        todo!()
    }

    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        todo!()
    }
}