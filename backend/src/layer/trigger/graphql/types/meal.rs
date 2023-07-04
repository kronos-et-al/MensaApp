use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::{util::{Additive, Allergen, Date, Uuid}, interface::persistent_data::model};

use super::{image::Image, side::Side};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Meal {
    id: Uuid,
    name: String,
    ratings: Ratings,
    price: Price,
    meal_statistics: MealStatistics,
}

#[ComplexObject]
impl Meal {
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        todo!()
    }

    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        todo!()
    }

    async fn images(&self, ctx: &Context<'_>) -> Result<Vec<Image>> {
        todo!()
    }

    async fn sides(&self, ctx: &Context<'_>) -> Result<Vec<Side>> {
        todo!()
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
}

#[ComplexObject]
impl Ratings {
    async fn personal_rating(&self, ctx: &Context<'_>) -> Result<Option<u32>> {
        todo!()
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
       }
    }
}
