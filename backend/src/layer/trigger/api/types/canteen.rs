use crate::{interface::persistent_data::model, layer::trigger::api::util::ApiUtil, util::Uuid};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::instrument;

use super::line::Line;

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
pub(in super::super) struct Canteen {
    /// The id of the canteen.
    id: Uuid,
    /// The name of the canteen.
    name: String,
}

#[ComplexObject]
impl Canteen {
    /// Provides the lines of the canteen.
    #[instrument(skip(ctx))]
    async fn lines(&self, ctx: &Context<'_>) -> Result<Vec<Line>> {
        let data = ctx.get_data_access();
        let lines = data
            .get_lines(self.id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(lines)
    }
}

impl From<model::Canteen> for Canteen {
    fn from(value: model::Canteen) -> Self {
        Self {
            id: value.id,
            name: value.name,
        }
    }
}
