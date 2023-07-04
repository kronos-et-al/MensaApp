use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::{Additive, Allergen, Date, Uuid}, interface::persistent_data::model};
use crate::layer::trigger::graphql::util::ApiUtil;

use super::{image::Image, side::Side};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Meal {
    id: Uuid,
    name: String,
    ratings: Ratings,
    price: Price,
    meal_statistics: MealStatistics,
    #[graphql(skip)]
    date: Date,
    #[graphql(skip)]
    line_id: Uuid
}

#[ComplexObject]
impl Meal {
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        let data_access = ctx.get_data_access();
        let allergens = data_access
            .get_allergens(self.id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(allergens)
    }

    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        let data_access = ctx.get_data_access();
        let additives = data_access
            .get_additives(self.id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(additives)
    }

    async fn images(&self, ctx: &Context<'_>) -> Result<Vec<Image>> {
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
        let images = data_access
            .get_visible_images(self.id, Some(client_id)) // TODO: should be changed, when authinfo is implemented 
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(images)
    }

    async fn sides(&self, ctx: &Context<'_>) -> Result<Vec<Side>> {
        let data_access = ctx.get_data_access();
        let sides = data_access
            .get_sides(self.line_id, self.date)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(sides)
    }
}

#[derive(SimpleObject)]
struct Price {
    student: u32,
    employee: u32,
    guest: u32,
    pupil: u32,
}

#[derive(SimpleObject)]
#[graphql(complex)]
struct Ratings {
    average_rating: f32,
    ratings_count: u32,
    #[graphql(skip)]
    meal_id: Uuid
}

#[ComplexObject]
impl Ratings {
    async fn personal_rating(&self, ctx: &Context<'_>) -> Result<Option<u32>> {
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_auth_info().client_id;
        let rating = data_access
            .get_personal_rating(self.meal_id, client_id)
            .await?;
        Ok(rating)
    }
}

#[derive(SimpleObject)]
struct MealStatistics {
    last_served: Option<Date>,
    next_served: Option<Date>,
    relative_frequency: f32,
}

impl From<model::Meal> for Meal {
    fn from(value: model::Meal) -> Self {
       Self {
           id: value.id,
           name: value.name,
           ratings: Ratings {
               average_rating: value.average_rating,
               ratings_count: value.rating_count,
               meal_id: value.id,
           },
           price: Price {
               student: value.price.price_student,
               employee: value.price.price_employee,
               guest: value.price.price_guest,
               pupil: value.price.price_pupil,
           },
           meal_statistics: MealStatistics {
               last_served: Option::from(value.last_served),
               next_served: Option::from(value.next_served),
               relative_frequency: value.relative_frequency,
           },
           date: value.date,
           line_id: value.line_id,
       }
    }
}
