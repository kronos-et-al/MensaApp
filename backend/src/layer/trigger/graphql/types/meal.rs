use async_graphql::{ComplexObject, Context, Result, SimpleObject};

use crate::layer::trigger::graphql::util::ApiUtil;
use crate::{
    interface::persistent_data::model,
    util::{Additive, Allergen, Date, Uuid},
};

use super::{image::Image, side::Side, price::Price};

#[derive(SimpleObject)]
#[graphql(complex)]
pub struct Meal {
    /// The identifier of the main course.
    id: Uuid,
    /// The name of the main course.
    name: String,
    /// The ratings given by the users to the meal.
    ratings: Ratings,
    /// The prices of the dish each for the four groups of people students, employees, pupils and guests.
    price: Price,
    /// The statistics for the meal. See MealStatistics TODO: link
    meal_statistics: MealStatistics,
    #[graphql(skip)]
    /// The date on which the meal is served. This is currently only used for getting sides.
    date: Date,
    #[graphql(skip)]
    /// The id of the line at which the meal is served. This is currently only used for getting sides.
    line_id: Uuid,
}

#[ComplexObject]
impl Meal {
    /// A function for getting the allergens of this meal
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

    /// A function for getting the additives of this meal
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

    /// A function for getting the images belonging to this meal
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

    /// A function for getting the sides belonging to this meal.
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
#[graphql(complex)]
struct Ratings {
    /// The average rating of this meal
    average_rating: f32,
    /// The total number of ratings for this meal
    ratings_count: u32,
    #[graphql(skip)]
    /// The id of the meal to which the ratings belong to. Currently used for getting the personal rating
    meal_id: Uuid,
}

#[ComplexObject]
impl Ratings {
    /// A function for getting this user's rating for the meal
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
    /// The date of the last time the meal was served
    last_served: Option<Date>,
    /// The date of the next time the meal will be served
    next_served: Option<Date>,
    /// The relative frequency with which the meal is offered. TODO
    relative_frequency: f32,
}

impl From<model::Meal> for Meal {
    /// A function for converting Meals from `persistent_data/model/meal` to types/meal 
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
