use async_graphql::{Object, Result, Context};

use crate::util::{Uuid, Date};

use super::types::canteen::Canteen;

/// Class implementing `GraphQLs` root queries.
pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn get_canteens(&self, ctx: &Context<'_>) -> Result<Vec<Canteen>> {
        todo!()
    }
    
    async fn get_canteen(&self, ctx: &Context<'_>, canteen_id: Uuid) -> Result<Vec<Canteen>> {
        todo!()
    }

    async fn get_meal(&self, ctx: &Context<'_>, meal_id: Uuid, line_id: Uuid, date: Date) -> Result<Option<Canteen>> {
        todo!()
    }

    
}
