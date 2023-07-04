use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{
    interface::persistent_data::{model, DataError::NoSuchItem},
    layer::trigger::graphql::util::ApiUtil,
    util::{Date, Uuid},
};

use super::{canteen::Canteen, meal::Meal};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Line {
    /// The id of the line
    id: Uuid,
    /// The name of the line
    name: String,
    #[graphql(skip)]
    /// The id of the canteen to which the line belongs. Currently only used for getting the canteen
    canteen_id: Uuid,
}

#[ComplexObject]
impl Line {
    /// A function for getting the canteen this line belongs to
    async fn canteen(&self, ctx: &Context<'_>) -> Result<Canteen> {
        let data_access = ctx.get_data_access();
        data_access
            .get_canteen(self.canteen_id)
            .await?
            .map(Into::into)
            .ok_or(NoSuchItem.into())
    }

    /// A function for getting the meals offered at this line on a given day. Requires a date
    async fn meals(&self, ctx: &Context<'_>, date: Date) -> Result<Vec<Meal>> {
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
        let meals = data_access
            .get_meals(self.id, date, client_id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(meals)
    }
}

impl From<model::Line> for Line {
    /// A function for converting Lines from `persistent_data/model/line` to types/line 
    fn from(value: model::Line) -> Self {
        Self {
            id: value.id,
            name: value.name,
            canteen_id: value.canteen_id,
        }
    }
}
