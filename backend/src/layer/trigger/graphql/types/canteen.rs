use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{
    interface::persistent_data::model, layer::trigger::graphql::util::ApiUtil, util::Uuid,
};

use super::line::Line;

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Canteen {
    /// The id of the canteen.
    id: Uuid,
    /// The name of the canteen.
    name: String,
}

#[ComplexObject]
impl Canteen {
    /// A function for getting the lines of the canteen
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
    /// A function for converting Canteens from `persistent_data/model/canteen` to types/canteen 
    fn from(value: model::Canteen) -> Self {
        Self {
            id: value.id,
            name: value.name,
        }
    }
}