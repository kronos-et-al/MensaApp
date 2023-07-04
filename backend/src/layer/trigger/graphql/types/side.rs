use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::{Additive, Allergen, Uuid}, interface::persistent_data::model};

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

impl From<model::Side> for Side {
    fn from(value: model::Side) -> Self {
        Self {
            id: value.id,
            name: value.name,
        }
    }
}
