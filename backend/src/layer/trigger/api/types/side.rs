use crate::util::FoodType;
use crate::{
    interface::persistent_data::model,
    layer::trigger::api::util::ApiUtil,
    util::{Additive, Allergen, Uuid},
};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::instrument;

use super::additional_data::{EnvironmentInfo, NutritionData};
use super::price::Price;

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
pub(in super::super) struct Side {
    /// The id of the side
    id: Uuid,
    /// The name of the side
    name: String,
    /// Here the type of meat which is contained in the side, or whether it is vegetarian or vegan, is specified.
    meal_type: FoodType,
    /// The price of the side
    price: Price,
}

#[ComplexObject]
impl Side {
    /// Provides the allergens of this side
    #[instrument(skip(ctx))]
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        let data_access = ctx.get_data_access();
        let allergens = data_access.get_allergens(self.id).await?;
        Ok(allergens)
    }

    /// Provides the additives of this side
    #[instrument(skip(ctx))]
    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        let data_access = ctx.get_data_access();
        let additives = data_access.get_additives(self.id).await?;
        Ok(additives)
    }

    /// Provides the environment information of this meal.
    #[instrument(skip(ctx))]
    async fn environment_info(&self, ctx: &Context<'_>) -> Result<Option<EnvironmentInfo>> {
        let data_access = ctx.get_data_access();
        let environment_info = data_access
            .get_environment_information(self.id)
            .await?
            .map(Into::into);
        Ok(environment_info)
    }

    /// Provides the nutrition data of this meal.
    #[instrument(skip(ctx))]
    async fn nutrition_data(&self, ctx: &Context<'_>) -> Result<Option<NutritionData>> {
        let data_access = ctx.get_data_access();
        let nutrition_data = data_access
            .get_nutrition_data(self.id)
            .await?
            .map(Into::into);
        Ok(nutrition_data)
    }
}

impl From<model::Side> for Side {
    fn from(value: model::Side) -> Self {
        Self {
            id: value.id,
            name: value.name,
            meal_type: value.food_type,
            price: Price {
                student: value.price.price_student,
                employee: value.price.price_employee,
                guest: value.price.price_guest,
                pupil: value.price.price_pupil,
            },
        }
    }
}
