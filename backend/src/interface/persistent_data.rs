//! The interfaces specified here allow access to data stored in a persistent datastore like a database.
pub mod model;

use crate::interface::persistent_data::model::{ApiKey, Canteen, Image, Line, Meal, Side};
use crate::util::{Additive, Allergen, Date, FoodType, NutritionData, Price, ReportReason, Uuid};
use async_trait::async_trait;
use model::ExtendedImage;
use sqlx::migrate::MigrateError;
use std::num::TryFromIntError;
use thiserror::Error;

use self::model::EnvironmentInfo;

use super::mensa_parser::model::ParseEnvironmentInfo;

/// Result returned from data access operations, potentially containing a [`DataError`].
pub type Result<T> = std::result::Result<T, DataError>;

/// Enumerations for possible data request faults
#[derive(Debug, Error)]
pub enum DataError {
    /// Requested data does not exist
    #[error("the requested item could not be found in the database")]
    NoSuchItem,
    /// Error occurred during data request or an internal connection fault.
    #[error("internal error ocurred: {0}")]
    InternalError(#[from] sqlx::Error),
    /// Failed to convert integers.
    #[error("error converting type: {0}")]
    TypeConversionError(#[from] TryFromIntError),
    /// Unexpectedly got null value from database.
    #[error("unexpectedly got null from database: {0}")]
    UnexpectedNullError(String),
    /// Database migration could not be run.
    #[error("error while running database migration: {0}")]
    MigrateError(#[from] MigrateError),
}

/// Extracts a value from an option by returning an [`DataError::UnexpectedNullError`] using [`std::ops::Try`] (`?`).
#[macro_export]
macro_rules! null_error {
    ($x:expr) => {
        $x.ok_or(
            $crate::interface::persistent_data::DataError::UnexpectedNullError(
                format!(
                    "{} at {}:{}:{}",
                    stringify!($x),
                    file!(),
                    line!(),
                    column!()
                )
                .to_string(),
            ),
        )?
    };
}

#[async_trait]
/// An interface for checking relations and inserting data structures. The MealPlanManagement component uses this interface for database access.
pub trait MealplanManagementDataAccess: Send + Sync {
    /// Removes all relations to the meal plan at the given date and the given canteen.
    /// Without removing changes in the meal plan couldn't be updated.
    async fn dissolve_relations(&self, canteen_id: Uuid, date: Date) -> Result<()>;

    /// Determines the canteen with the most similar name.
    /// Returns the UUID to the similar canteen.
    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Uuid>>;

    /// Determines the line with the most similar name.
    /// Returns the UUID to the similar line.
    async fn get_similar_line(&self, similar_name: &str, canteen_id: Uuid) -> Result<Option<Uuid>>;

    /// Determines the meal with the most similar name, identical allergens and identical additives.
    /// Returns the UUID to the similar meal.
    async fn get_similar_meal(
        &self,
        similar_name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>>;

    /// Determines the side with the most similar name, identical allergens and identical additives.
    /// Returns the UUID to the similar canteen.
    async fn get_similar_side(
        &self,
        similar_name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>>;

    /// Updates an existing canteen entity in the database.
    /// Returns the canteen's UUID.
    async fn update_canteen(&self, uuid: Uuid, name: &str, position: u32) -> Result<()>;

    /// Updates an existing line entity in the database.
    /// Returns the line UUID.
    async fn update_line(&self, uuid: Uuid, name: &str, position: u32) -> Result<()>;

    /// Updates an existing meal entity in the database.
    /// Behavior is undefined, if the specified UUID is a side.
    /// Nutrition and environmental data will be updated as well, as they can change over time.
    async fn update_meal(
        &self,
        uuid: Uuid,
        name: &str,
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<()>;

    /// Updates an existing side entity in the database.
    /// Behavior is undefined, if the specified UUID is a meal.
    /// Nutrition and environmental data will be updated as well, as they can change over time.
    async fn update_side(
        &self,
        uuid: Uuid,
        name: &str,
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<()>;

    /// Adds a new canteen entity to the database.
    /// Returns UUID of the new canteen.
    async fn insert_canteen(&self, name: &str, position: u32) -> Result<Uuid>;

    /// Adds a new line entity to the database.
    /// Returns uuid of the new line.
    async fn insert_line(&self, canteen_id: Uuid, name: &str, position: u32) -> Result<Uuid>;

    /// Adds a new meal entity to the database. Returns the UUID of the created meal.
    async fn insert_meal(
        &self,
        name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid>;

    /// Adds a new side entity to the database. Returns the UUID of the created meal.
    async fn insert_side(
        &self,
        name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid>;

    /// Adds a meal into the meal plan for a line at a date by specifying its price.
    /// Behavior is undefined, if the specified UUID is a side.
    async fn add_meal_to_plan(
        &self,
        meal_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()>;

    /// Adds a side into the meal plan for a line at a date by specifying its price.
    /// Behavior is undefined, if the specified UUID is a meal.
    async fn add_side_to_plan(
        &self,
        side_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()>;
}

#[async_trait]
/// An interface for api actions. The Command component uses this interface for database access.
pub trait CommandDataAccess: Sync + Send {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(&self, image_id: Uuid) -> Result<ExtendedImage>;
    /// Marks an image as hidden. Hidden images cant be seen by users.
    async fn hide_image(&self, image_id: Uuid) -> Result<()>;
    /// Saves an image report
    async fn add_report(&self, image_id: Uuid, client_id: Uuid, reason: ReportReason)
        -> Result<()>;
    /// Adds an upvote to the given image. An user can only down- or upvote an image.
    async fn add_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Adds a downvote to the given image. An user can only down- or upvote an image.
    async fn add_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Removes an upvote from the given image.
    async fn remove_upvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Removes a downvote from the given image.
    async fn remove_downvote(&self, image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Adds an image link to the database. The image will be related to the given meal.
    async fn link_image(&self, meal_id: Uuid, user_id: Uuid) -> Result<Uuid>;

    /// Reverts the linking of the given image by deleting the link.
    /// Useful if an error ocurred with the image itself.
    async fn revert_link_image(&self, image_id: Uuid) -> Result<()>;

    /// Adds or updates a rating to the database. The rating will be related to the given meal and the given user.
    async fn add_rating(&self, meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()>;

    /// Marks an image as verified. This leads to future reports being ignored.
    async fn verify_image(&self, image_id: Uuid) -> Result<()>;

    /// Deletes all entries related to an image.
    async fn delete_image(&self, image_id: Uuid) -> Result<()>;
}

/// An interface for database access necessary for the authentication process.
#[async_trait]
pub trait AuthDataAccess: Sync + Send {
    /// Loads all api_keys from the database.
    async fn get_api_keys(&self) -> Result<Vec<ApiKey>>;
}

#[async_trait]
/// An interface for graphql query data. The GraphQL component uses this interface for database access.
pub trait RequestDataAccess: Send + Sync {
    /// Returns the canteen from the database.
    async fn get_canteen(&self, id: Uuid) -> Result<Option<Canteen>>;
    /// Returns all canteens from the database.
    async fn get_canteens(&self) -> Result<Vec<Canteen>>;
    /// Returns the line from the database.
    async fn get_line(&self, id: Uuid) -> Result<Option<Line>>;
    /// Returns all lines of a canteen from the database.
    async fn get_lines(&self, canteen_id: Uuid) -> Result<Vec<Line>>;
    /// Returns the meal related to all the params.
    async fn get_meal(&self, id: Uuid, line_id: Uuid, date: Date) -> Result<Option<Meal>>;
    /// Returns all meals related to all the params. Null is returned when there is not any information available yet.
    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>>;
    /// Returns all sides of a line at the given day from the database.
    async fn get_sides(&self, line_id: Uuid, date: Date) -> Result<Vec<Side>>;
    /// Returns all images, which are related to the given user or meal. Images reported by the user will not be returned.
    async fn get_visible_images(
        &self,
        meal_id: Uuid,
        client_id: Option<Uuid>,
    ) -> Result<Vec<Image>>;
    /// Returns the rating done by the given user for the given meal.
    async fn get_personal_rating(&self, meal_id: Uuid, client_id: Uuid) -> Result<Option<u32>>;
    /// Checks if the given image got an upvote by the given user
    async fn get_personal_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<bool>;
    /// Checks if the given image got an downvote by the given user
    async fn get_personal_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<bool>;
    /// Returns all additives related to the given food_id (food_id can be a meal_id or side_id).
    async fn get_additives(&self, food_id: Uuid) -> Result<Vec<Additive>>;
    /// Returns all allergens related to the given food_id (food_id can be a meal_id or side_id).
    async fn get_allergens(&self, food_id: Uuid) -> Result<Vec<Allergen>>;
    /// Returns the nutritionial data related to the given food_id (food_id can be a meal_id or side_id).
    async fn get_nutrition_data(&self, food_id: Uuid) -> Result<Option<NutritionData>>;
    /// Returns the environmental data related to the given food_id (food_id can be a meal_id or side_id).
    async fn get_environment_information(&self, food_id: Uuid) -> Result<Option<EnvironmentInfo>>;
}
