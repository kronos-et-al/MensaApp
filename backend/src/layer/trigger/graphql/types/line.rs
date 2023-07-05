use crate::layer::trigger::graphql::util::{TRACE_QUERY_MESSAGE};
use crate::{
    interface::persistent_data::model,
    layer::trigger::graphql::util::ApiUtil,
    util::{Date, Uuid},
};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::{instrument, trace};

use super::{canteen::Canteen, meal::Meal};

#[derive(SimpleObject, Debug)]
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
    #[instrument(skip(ctx))]
    #[graphql(complexity = "10 * child_complexity")]
    async fn canteen(&self, ctx: &Context<'_>) -> Result<Canteen> {
        // TODO Option when no data available?
        trace!(TRACE_QUERY_MESSAGE);
        let data_access = ctx.get_data_access();
        data_access
            .get_canteen(self.canteen_id)
            .await?
            .map(Into::into)
            .ok_or_else(|| "internal error: each line must belong to a canteen".into())
    }

    /// A function for getting the meals offered at this line on a given day. Requires a date
    #[instrument(skip(ctx))]
    async fn meals(&self, ctx: &Context<'_>, date: Date) -> Result<Vec<Meal>> {
        trace!(TRACE_QUERY_MESSAGE);
        let data_access = ctx.get_data_access();
        let meals = data_access
            .get_meals(self.id, date)
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
