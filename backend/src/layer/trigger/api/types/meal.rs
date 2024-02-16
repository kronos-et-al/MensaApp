use crate::layer::trigger::api::util::ApiUtil;
use crate::util::FoodType;
use crate::{
    interface::persistent_data::model,
    util::{Additive, Allergen, Date, Uuid},
};
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use tracing::instrument;

use super::additional_data::NutritionData;
use super::line::Line;
use super::{additional_data::EnvironmentInfo, image::Image, price::Price, side::Side};

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
#[allow(clippy::struct_field_names)]
pub(in super::super) struct Meal {
    /// The identifier of the main course.
    id: Uuid,
    /// The name of the main course.
    name: String,
    /// Type of this meal.
    /// Here the type of meat which is contained in the meal, or whether it is vegetarian or vegan, is specified.
    meal_type: FoodType,
    /// The ratings given by the users to the meal.
    ratings: Ratings,
    /// The prices of the dish each for the four groups of people students, employees, pupils and guests.
    price: Price,
    /// Some statistics for the meal.
    statistics: MealStatistics,
    #[graphql(skip)]
    date: Date,
    #[graphql(skip)]
    line_id: Uuid,
}

#[ComplexObject]
impl Meal {
    /// Provides the allergens of this meal.
    #[instrument(skip(ctx))]
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

    /// Provides the additives of this meal
    #[instrument(skip(ctx))]
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

    /// Provides the images belonging to this meal
    #[instrument(skip(ctx))]
    async fn images(&self, ctx: &Context<'_>) -> Result<Vec<Image>> {
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_client_id().ok();
        let images = data_access
            .get_visible_images(self.id, client_id)
            .await?
            .into_iter()
            .map(Into::into)
            .collect();
        Ok(images)
    }

    /// Provides the sides belonging to this meal.
    #[instrument(skip(ctx))]
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

    /// Provides the line this meal is served at.
    #[instrument(skip(ctx))]
    async fn line(&self, ctx: &Context<'_>) -> Result<Line> {
        let data_access = ctx.get_data_access();
        data_access
            .get_line(self.line_id)
            .await?
            .map(Into::into)
            .ok_or_else(|| "internal error: each meal must belong to a line".into())
    }

    /// Provides the environment information of this meal.
    #[instrument(skip(ctx))]
    async fn environment_info(&self, ctx: &Context<'_>) -> Result<Option<EnvironmentInfo>> {
        let data_access = ctx.get_data_access();
        let environement_info = data_access
            .get_environment_information(self.id)
            .await?
            .map(Into::into);
        Ok(environement_info)
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

#[derive(SimpleObject, Debug)]
#[graphql(complex)]
#[allow(clippy::struct_field_names)]
struct Ratings {
    /// The average rating of this meal.
    average_rating: f32,
    /// The total number of ratings for this meal.
    ratings_count: u32,
    #[graphql(skip)]
    meal_id: Uuid,
}

#[ComplexObject]
impl Ratings {
    /// Provides this user's rating for the meal.
    /// Therefor a client id must be provided in the authorization header (see https://github.com/kronos-et-al/MensaApp/blob/main/doc/ApiAuth.md).
    #[instrument(skip(ctx))]
    async fn personal_rating(&self, ctx: &Context<'_>) -> Result<Option<u32>> {
        let data_access = ctx.get_data_access();
        let client_id = ctx.get_client_id()?;
        let rating = data_access
            .get_personal_rating(self.meal_id, client_id)
            .await?;
        Ok(rating)
    }
}

#[derive(SimpleObject, Debug)]
struct MealStatistics {
    /// The date of the last time the meal was served.
    last_served: Option<Date>,
    /// The date of the next time the meal will be served.
    next_served: Option<Date>,
    /// Count how often meal was served in the last three months.
    frequency: u32,
    /// Whether this meal is new and was never served before.
    new: bool,
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
            statistics: MealStatistics {
                last_served: value.last_served,
                next_served: value.next_served,
                frequency: value.frequency,
                new: value.new,
            },
            date: value.date,
            line_id: value.line_id,
            meal_type: value.food_type,
        }
    }
}
