use async_graphql::{Context, Object, Result};

use crate::util::{Date, Uuid};

use super::{types::canteen::Canteen, util::ApiUtil};

/// Class implementing `GraphQLs` root queries.
pub struct QueryRoot;

#[Object]
impl QueryRoot {
    /// This query returns a list of all available canteens.
    async fn get_canteens(&self, ctx: &Context<'_>) -> Result<Vec<Canteen>> {
        let data = ctx.get_data_access();
        let canteens = data
            .get_canteens()
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(canteens)
    }

    async fn get_canteen(&self, ctx: &Context<'_>, canteen_id: Uuid) -> Result<Vec<Canteen>> {
        todo!()
    }

    async fn get_meal(
        &self,
        ctx: &Context<'_>,
        meal_id: Uuid,
        line_id: Uuid,
        date: Date,
    ) -> Result<Option<Canteen>> {
        todo!()
    }

    // TODO
    async fn test(&self) -> String {
        "hello world!".into()
    }
}
