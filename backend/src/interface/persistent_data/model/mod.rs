//! These structs are used for database operations
use crate::util;
use chrono::{DateTime, Local};
use std::string::String;
use util::MealType;
use uuid::Uuid;

/// Enumerations for possible data request faults
pub enum DataError {
    /// Requested data does not exist
    NoSuchItem,
    /// Error occurred during data request or an internal connection fault
    InternalError,
}

/// Struct to storage related data. Contains all api-key related information.
pub struct ApiKey {
    /// The api-key
    key: String,
    /// An short description for the api-key.
    description: String,
}

/// Struct for database-operations. Related to the database entity 'canteen'.
pub struct Canteen {
    /// Identification of the canteen
    id: Uuid,
    /// Name of the canteen
    name: String,
}
/// Struct for database-operations. Related to the database entity 'line'.
pub struct Line {
    /// Identification of the line
    id: Uuid,
    /// Name of the line
    name: String,
}
/// Struct for database-operations. Related to the database entity 'meal'.
pub struct Meal {
    /// Identification of the meal.
    id: Uuid,
    /// Name of the meal.
    name: String,
    /// Type of the meal.
    meal_type: MealType,
    /// Price of the meal for students, employees, guests and pupils.
    price_student: u32,
    price_employee: u32,
    price_guest: u32,
    price_pupil: u32,
    /// The DateTime the meal was last served.
    last_served: DateTime<Local>,
    /// The DateTime when the meal will be served next.
    next_served: DateTime<Local>,

    /// Relative frequency of the meal in the mealplan.
    relative_frequency: f32,
    /// Amount of ratings for the meal
    rating_count: u32,
    /// The average rating of the meal
    average_rating: f32,
}
/// This structure is used for database operations. This side structure is based on the database entities 'food', 'foodAllergen' and 'foodAdditive'.
pub struct Side {
    /// Identification of the side.
    id: Uuid,
    /// Name of the side.
    name: String,
    /// Type of the side.
    meal_type: MealType,
    /// Price of the side for students, employees, guests and pupils.
    price_student: u32,
    price_employee: u32,
    price_guest: u32,
    price_pupil: u32,
}
/// This structure is used for database operations. This image structure is based on the database entity 'image'.
pub struct Image {
    /// Database-identification of the image.
    id: Uuid,
    /// Image-identification of the image-hoster.
    image_hoster_id: String,
    /// Direct link to the image on the image-hoster website.
    url: String,
    /// Rank of the image. Used for sorting und prioritizing an image.
    rank: f32,
    /// Amount of upvotes for the image.
    upvotes: u32,
    /// Amount of downvotes for the image.
    downvotes: u32,
}
pub struct ImageInfo {
    /// True if an administrator valiDateTimed the image.
    approved: bool,
    /// Upload-DateTime of the image.
    upload_date: DateTime<Local>,
    /// Amount of open report request related to that image.
    report_count: u32,
    /// Direct link to the image on the image-hoster website.
    image_url: String,
    /// Amount of upvotes for the image.
    positive_rating_count: u32,
    /// Amount of downvotes for the image.
    negative_rating_count: u32,
    /// Rank of the image. Used for sorting und prioritizing an image.
    image_rank: f32,
}
