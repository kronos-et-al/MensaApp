use crate::layer::trigger::graphql::util::{trace_query_request, ApiUtil};
use crate::util::MealType;
use crate::{
    interface::persistent_data::model,
    util::{Additive, Allergen, Date, Uuid},
};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::instrument;

use super::line::Line;
use super::{image::Image, price::Price, side::Side};

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
pub struct Meal {
    /// The identifier of the main course.
    id: Uuid,
    /// The name of the main course.
    name: String,
    /// Type of this meal.
    /// Here the type of meat which is contained in the meal, or whether it is vegetarian or vegan, is specified.
    meal_type: MealType,
    /// The ratings given by the users to the meal.
    ratings: Ratings,
    /// The prices of the dish each for the four groups of people students, employees, pupils and guests.
    price: Price,
    /// Some statistics for the meal.
    statistics: MealStatistics,
    #[graphql(skip)]
    /// The date on which the meal is served. This is currently only used for getting sides.
    date: Date,
    #[graphql(skip)]
    /// The id of the line at which the meal is served. This is currently only used for getting sides.
    line_id: Uuid,
}

#[ComplexObject]
impl Meal {
    // TODO these should not be called "functions" as they are just attributes in a graphql context.
    /// A function for getting the allergens of this meal
    #[instrument(skip(ctx))]
    async fn allergens(&self, ctx: &Context<'_>) -> Result<Vec<Allergen>> {
        trace_query_request();
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
    #[instrument(skip(ctx))]
    async fn additives(&self, ctx: &Context<'_>) -> Result<Vec<Additive>> {
        trace_query_request();
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
    #[instrument(skip(ctx))]
    async fn images(&self, ctx: &Context<'_>) -> Result<Vec<Image>> {
        trace_query_request();
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_auth_info().map(|i| i.client_id);
        let images = data_access
            .get_visible_images(self.id, client_id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(images)
    }

    /// A function for getting the sides belonging to this meal.
    #[instrument(skip(ctx))]
    async fn sides(&self, ctx: &Context<'_>) -> Result<Vec<Side>> {
        trace_query_request();
        let data_access = ctx.get_data_access();
        let sides = data_access
            .get_sides(self.line_id, self.date)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(sides)
    }

    /// A function for getting the line this meal is served at.
    #[instrument(skip(ctx))]
    #[graphql(complexity = "10 * child_complexity")]
    async fn line(&self, ctx: &Context<'_>) -> Result<Line> {
        trace_query_request();
        let data_access = ctx.get_data_access();
        data_access
            .get_line(self.line_id)
            .await?
            .map(Into::into)
            .ok_or_else(|| "internal error: each meal must belong to a line".into())
    }
}

#[derive(SimpleObject, Debug)]
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
    #[instrument(skip(ctx))]
    async fn personal_rating(&self, ctx: &Context<'_>) -> Result<Option<u32>> {
        trace_query_request();
        let data_access = ctx.get_data_access();
        let client_id = match ctx.get_auth_info() {
            Some(info) => info.client_id,
            None => return Ok(None),
        };
        let rating = data_access
            .get_personal_rating(self.meal_id, client_id)
            .await?;
        Ok(rating)
    }
}

#[derive(SimpleObject, Debug)]
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
            statistics: MealStatistics {
                last_served: Option::from(value.last_served), // todo these here should not be options all the way from the model
                next_served: Option::from(value.next_served),
                relative_frequency: value.relative_frequency,
            },
            date: value.date,
            line_id: value.line_id,
            meal_type: value.meal_type,
        }
    }
}
