//! These structs are used for database operations
use crate::util::{self, Date};
use crate::util::{Additive, Allergen, Price};
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
    pub key: String,
    /// An short description for the api-key.
    pub description: String,
}

/// Struct for database-operations. Related to the database entity 'canteen'.
pub struct Canteen {
    /// Identification of the canteen
    pub id: Uuid,
    /// Name of the canteen
    pub name: String,
    /// All related lines.
    pub lines: Vec<Line>,
}

/// Struct for database-operations. Related to the database entity 'line'.
pub struct Line {
    /// Identification of the line
    pub id: Uuid,
    /// Name of the line
    pub name: String,
    /// All related meals.
    pub meals: Vec<Meal>,
    /// All related meals.
    pub sides: Vec<Side>,
}

/// Struct for database-operations. Related to the database entity 'meal'.
pub struct Meal {
    /// Identification of the meal.
    pub id: Uuid,
    /// Name of the meal.
    pub name: String,
    /// Type of the meal.
    pub meal_type: MealType,
    /// Price of the meal for students, employees, guests and pupils.
    pub price: Price,
    /// The DateTime the meal was last served.
    pub last_served: Date,
    /// The DateTime when the meal will be served next.
    pub next_served: Date,
    /// Relative frequency of the meal in the mealplan.
    pub relative_frequency: f32,
    /// Amount of ratings for the meal
    pub rating_count: u32,
    /// The average rating of the meal
    pub average_rating: f32,
    /// All containing allergens.
    pub allergens: Vec<Allergen>,
    /// All containing additives.
    pub additives: Vec<Additive>,
}

/// This structure is used for database operations. This side structure is based on the database entities 'food', 'foodAllergen' and 'foodAdditive'.
pub struct Side {
    /// Identification of the side.
    pub id: Uuid,
    /// Name of the side.
    pub name: String,
    /// Type of the side.
    pub meal_type: MealType,
    /// Price of the side for students, employees, guests and pupils.
    pub price: Price,
    /// All containing allergens.
    pub allergens: Vec<Allergen>,
    /// All containing additives.
    pub additives: Vec<Additive>,
}

/// This structure is used for database operations. This image structure is based on the database entity 'image'.
pub struct Image {
    /// Database-identification of the image.
    pub id: Uuid,
    /// Image-identification of the image-hoster.
    pub image_hoster_id: String,
    /// Direct link to the image on the image-hoster website.
    pub url: String,
    /// Rank of the image. Used for sorting und prioritizing an image.
    pub rank: f32,
    /// Amount of upvotes for the image.
    pub upvotes: u32,
    /// Amount of downvotes for the image.
    pub downvotes: u32,
}

pub struct ImageInfo {
    /// True if an administrator valiDateTimed the image.
    pub approved: bool,
    /// Upload-DateTime of the image.
    pub upload_date: Date,
    /// Amount of open report request related to that image.
    pub report_count: u32,
    /// Direct link to the image on the image-hoster website.
    pub image_url: String,
    /// Amount of upvotes for the image.
    pub positive_rating_count: u32,
    /// Amount of downvotes for the image.
    pub negative_rating_count: u32,
    /// Rank of the image. Used for sorting und prioritizing an image.
    pub image_rank: f32,
}
