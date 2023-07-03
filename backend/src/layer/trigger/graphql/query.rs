use async_graphql::{Context, Object, Result};

use crate::util::{Date, Uuid};

use super::{types::canteen::Canteen, util::ApiUtil, types::meal::Meal};

/// Class implementing `GraphQLs` root queries.
pub struct QueryRoot;

#[Object]
impl QueryRoot {
    /// This query returns a list of all available canteens.
    async fn get_canteens(
        &self, 
        ctx: &Context<'_>
    ) -> Result<Vec<Canteen>> {
        let data = ctx.get_data_access();
        let canteens = data
            .get_canteens()
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(canteens)
    }

    /// This query returns the canteen identified by the specified ID.
    /// If there is no canteen with the specified ID, a null value is returned.
    async fn get_canteen(
        &self, 
        ctx: &Context<'_>, 
        #[graphql(desc = "Id of the canteen to get.")] canteen_id: Uuid
    ) -> Result<Option<Canteen>> {
        let data = ctx.get_data_access();
        let canteen = data
            .get_canteen(canteen_id)
            .await?
            .map(Into::into);
        Ok(canteen)
    }

    /// This query returns the main dish (including its price and sides) identified by the specified ID, the line and the date.
    /// If the main dish does not exist, or is not served at the specified line on the specified day, a null value is returned. 
    async fn get_meal(
        &self,
        ctx: &Context<'_>,
        #[graphql(desc = "Id of the meal to get.")] meal_id: Uuid,
        #[graphql(desc = "Id of the line at which the meal to get is to be offered.")] line_id: Uuid,
        #[graphql(desc = "Date of the day on which the meal to get is to be offered.")] date: Date,
    ) -> Result<Option<Meal>> {
        let data = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
        let meal = data
            .get_meal(meal_id, line_id, date, client_id)
            .await?
            .map(Into::into);
        Ok(meal)
    }

    // TODO
    async fn test(&self) -> String {
        "hello world!".into()
    }
}
