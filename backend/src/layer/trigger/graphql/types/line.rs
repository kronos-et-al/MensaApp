use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::{Date, Uuid}, interface::persistent_data::{model, DataError::NoSuchItem}, layer::{trigger::graphql::util::ApiUtil}};

use super::{canteen::Canteen, meal::Meal};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Line {
    id: Uuid,
    name: String,
    #[graphql(skip)] 
    canteen_id: Uuid,
}

#[ComplexObject]
impl Line {
    async fn canteen(&self, ctx: &Context<'_>) -> Result<Canteen> {
        let data_access = ctx.get_data_access();
        data_access
            .get_canteen(self.canteen_id)
            .await?
            .map(Into::into)
            .ok_or(NoSuchItem.into())
    }

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
    fn from(value: model::Line) -> Self {
        Self {
            id: value.id,
            name: value.name,
            canteen_id: value.canteen_id,
        }
    }
}
