//! The interfaces specified here allow access to data stored in a persistent datastore like a database.
use crate::interface::persistent_data::model::{
    ApiKey, Canteen, DataError, Image, ImageInfo, Line, Meal, Side,
};

use crate::util::{Additive, Allergen, Date, MealType, Price, ReportReason};
use async_trait::async_trait;
use chrono::{DateTime, Local};
use uuid::Uuid;

pub mod model;



pub type Result<T> = std::result::Result<T, DataError>;

#[async_trait]
/// An interface for checking relations and inserting data structures. The MealplanManagement component uses this interface for database access.
pub trait MealplanManagementDataAccess {
    /// Determines all canteens with a similar name.
    async fn get_similar_canteens(similar_name: String) -> Result<Vec<Canteen>>;
    /// Determines all lines with a similar name.
    async fn get_similar_lines(similar_name: String) -> Result<Vec<Line>>;
    /// Determines all meals with a similar name.
    async fn get_similar_meals(similar_name: String) -> Result<Vec<Meal>>;
    /// Determines all sides with a similar name.
    async fn get_similar_sides(similar_name: String) -> Result<Vec<Side>>;

    /// Updates an existing canteen entity in the database. Returns the entity.
    async fn update_canteen(uuid: Uuid, name: String) -> Result<Canteen>;
    /// Updates an existing line entity in the database. Returns the entity.
    async fn update_line(uuid: Uuid, name: String) -> Result<Line>;
    /// Updates an existing meal entity in the database. Returns the entity.
    async fn update_meal(
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: String,
        price: Price,
    ) -> Result<Meal>;
    /// Updates an existing side entity in the database. Returns the entity.
    async fn update_side(
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: String,
        price: Price,
    ) -> Result<Side>;

    /// Adds a new canteen entity to the database. Returns the new entity.
    async fn insert_canteen(name: String) -> Result<Canteen>;
    /// Adds a new line entity to the database. Returns the new entity.
    async fn insert_line(name: String) -> Result<Line>;
    /// Adds a new meal entity to the database. Returns the new entity.
    async fn insert_meal(
        name: String,
        c_type: MealType,
        price: Price,
        next_served: Date,
        allergens: Vec<Allergen>,
        additives: Vec<Additive>,
    ) -> Result<Meal>;
    /// Adds a new side entity to the database. Returns the new entity.
    async fn insert_side(
        name: String,
        c_type: MealType,
        price: Price,
        next_served: Date,
        allergens: Vec<Allergen>,
        additives: Vec<Additive>,
    ) -> Result<Side>;
}

#[async_trait]
/// An interface for image related data. The ImageReview component uses this interface for database access.
pub trait ImageReviewDataAccess {
    /// Returns the first n images sorted by rank which are related to an meal served at the given day.
    async fn get_n_images_by_rank_date(n: u32, date: Date) -> Result<Vec<Image>>;
    /// Returns the first n images sorted by rank which are related to an meal served in the next week or which were not validated last week.
    async fn get_n_images_next_week_by_rank_not_checked_last_week(n: u32) -> Result<Vec<Image>>;
    /// Returns the first n images sorted by the date of the last check (desc) which were not validated in the last week.
    async fn get_n_images_by_last_checked_not_checked_last_week(n: u32) -> Result<Vec<Image>>;
    /// Removes an image with all relations from the database.
    async fn delete_image(id: Uuid) -> Result<bool>;
    /// Marks all images identified by the given uuids as checked.
    async fn mark_as_checked(ids: Vec<Uuid>) -> Result<()>;
}

#[async_trait]
/// An interface for graphql mutation data manipulation. The Command component uses this interface for database access.
pub trait CommandDataAccess {
    /// Returns the ImageInfo struct of image.
    async fn get_image_info(image_id: Uuid) -> Result<ImageInfo>;
    /// Marks an image as hidden. Hidden images cant be seen by users.
    async fn hide_image(image_id: Uuid) -> Result<()>;
    /// Saves an image report
    async fn add_report(image_id: Uuid, client_id: Uuid, reason: ReportReason) -> Result<()>;
    /// Adds an upvote to the given image. An user can only down- or upvote an image.
    async fn add_upvote(image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Adds a downvote to the given image. An user can only down- or upvote an image.
    async fn add_downvote(image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Removes an upvote from the given image.
    async fn remove_upvote(image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Removes a downvote from the given image.
    async fn remove_downvote(image_id: Uuid, user_id: Uuid) -> Result<()>;
    /// Adds an image link to the database. The image will be related to the given meal.
    async fn link_image(
        meal_id: Uuid,
        user_id: Uuid,
        image_hoster_id: String,
        url: String,
    ) -> Result<()>;
    /// Adds a rating to the database. The rating will be related to the given meal and the given user.
    async fn add_rating(meal_id: Uuid, user_id: Uuid, rating: u32) -> Result<()>;
    /// Loads all api_keys from the database.
    async fn get_api_keys() -> Result<Vec<ApiKey>>;
}

#[async_trait]
/// An interface for graphql query data. The GraphQL component uses this interface for database access.
pub trait RequestDataAccess {
    /// Returns the canteen from the database.
    async fn get_canteen(id: Uuid) -> Result<Option<Canteen>>;
    /// Returns all canteens from the database.
    async fn get_canteens() -> Result<Vec<Canteen>>;
    /// Returns all lines of a canteen from the database.
    async fn get_lines(canteen_id: Uuid) -> Result<Vec<Line>>;
    /// Returns the meal related to all the params.
    async fn get_meal(id: Uuid, line_id: Uuid, date: Date, client_id: Uuid)
        -> Result<Option<Meal>>;
    /// Returns all meals related to all the params.
    async fn get_meals(line_id: Uuid, date: Date, client_id: Uuid) -> Result<Vec<Meal>>;
    /// Returns all sides of a line at the given day from the database.
    async fn get_sides(line_id: Uuid, date: Date) -> Result<Vec<Side>>;
    /// Returns all images, which are related to the given user or meal. Images reported by the user will not be returned.
    async fn get_visible_images(meal_id: Uuid, client_id: Option<Uuid>) -> Result<Vec<Image>>;
    /// Returns the rating done by the given user for the given meal.
    async fn get_personal_rating(meal_id: Uuid, client_id: Uuid) -> Result<Option<u32>>;
    /// Checks if the given image got an upvote by the given user
    async fn get_personal_upvote(image_id: Uuid, client_id: Uuid) -> Result<bool>;
    /// Checks if the given image got an downvote by the given user
    async fn get_personal_downvote(image_id: Uuid, client_id: Uuid) -> Result<bool>;
}
