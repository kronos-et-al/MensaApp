use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::Uuid, interface::persistent_data::model, layer::trigger::graphql::util::ApiUtil};

use super::line::Line;


#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Canteen {
    id: Uuid,
    name: String,
}

#[ComplexObject]
impl Canteen {
    async fn lines(&self, ctx: &Context<'_>) -> Result<Vec<Line>> {
        let data = ctx.get_data_access();
        let lines = data.get_lines(self.id)
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