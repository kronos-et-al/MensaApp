use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{
    interface::persistent_data::model,
    layer::trigger::graphql::util::ApiUtil,
    util::{Additive, Allergen, Uuid},
};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Side {
    /// The id of the side
    id: Uuid,
    /// The name of the side
    name: String,
}

#[ComplexObject]
impl Side {
    /// A function for getting the allergens of this side
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        let data_access = ctx.get_data_access();
        let allergens = data_access
            .get_allergens(self.id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(allergens)
    }

    /// A function for getting the additives of this side
    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        let data_access = ctx.get_data_access();
        let additives = data_access
            .get_additives(self.id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(additives)
    }
}

impl From<model::Side> for Side {
    /// A function for converting Sides from `persistent_data/model/side` to types/side 
    fn from(value: model::Side) -> Self {
        Self {
            id: value.id,
            name: value.name,
        }
    }
}
