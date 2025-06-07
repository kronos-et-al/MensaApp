//! These structs are used for database operations.
use crate::util::Price;
use crate::util::{self, Date};

use util::{FoodType, Uuid};

/// Struct to storage related data. Contains all api-key related information.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct ApiKey {
    /// The api-key
    pub key: String,
    /// An short description for the api-key.
    pub description: String,
}

/// Struct for database-operations. Related to the database entity 'canteen'.
#[derive(Debug, Clone)]
pub struct Canteen {
    /// Identification of the canteen
    pub id: Uuid,
    /// Name of the canteen
    pub name: String,
}

/// Struct for database-operations. Related to the database entity 'line'.
#[derive(Debug, Clone)]
pub struct Line {
    /// Identification of the line
    pub id: Uuid,
    /// Name of the line
    pub name: String,
    /// The id of the canteen to which the line belongs
    pub canteen_id: Uuid,
}

/// Struct for database-operations. Related to the database entity 'meal'.
#[derive(Debug, PartialEq, Clone)]
pub struct Meal {
    /// Identification of the meal.
    pub id: Uuid,
    /// Name of the meal.
    pub name: String,
    /// Type of the meal.
    pub food_type: FoodType,
    /// Price of the meal for students, employees, guests and pupils.
    pub price: Price,
    /// The date the meal was last served.
    pub last_served: Option<Date>,
    /// The date when the meal will be served next.
    pub next_served: Option<Date>,
    /// Count how often meal was served in the last three months.
    pub frequency: u32,
    /// Whether this meal is new and was never served before.
    pub new: bool,
    /// Amount of ratings for the meal
    pub rating_count: u32,
    /// The average rating of the meal
    pub average_rating: f32,
    /// The date on which the meal is served
    pub date: Date,
    /// The id of the line at which the meal is served
    pub line_id: Uuid,
}

/// This structure is used for database operations. This side structure is based on the database entities 'food', 'foodAllergen' and 'foodAdditive'.
#[derive(Debug, PartialEq, Eq, Clone)]
pub struct Side {
    /// Identification of the side.
    pub id: Uuid,
    /// Name of the side.
    pub name: String,
    /// Type of the side.
    pub food_type: FoodType,
    /// Price of the side for students, employees, guests and pupils.
    pub price: Price,
}

/// This structure is used for database operations. This image structure is based on the database entity 'image'.
#[derive(Debug, Default, PartialEq, Clone)]
pub struct Image {
    /// Database-identification of the image.
    pub id: Uuid,
    /// Rank of the image. Used for sorting und prioritizing an image.
    pub rank: f32,
    /// Amount of upvotes for the image.
    pub upvotes: u32,
    /// Amount of downvotes for the image.
    pub downvotes: u32,
    /// True if an administrator validated the image.
    pub approved: bool,
    /// Upload date of the image.
    pub upload_date: Date,
    /// Amount of open report request related to that image.
    pub report_count: u32,
    /// Id of the meal this image belongs to.
    pub meal_id: Uuid,
    /// User ids of users that reported this image. May not be filled with data.
    pub reporting_users: Option<Vec<Uuid>>,
}

/// This structure contains all information of an image necessary to file a report.
#[derive(Debug, Default, PartialEq, Clone)]
pub struct ExtendedImage {
    /// Information that can be directly queried from the image and is also useful elsewhere, see [Image].
    pub image: Image,
    /// Name of the meal this image belongs to.
    pub meal_name: String,
    /// List of urls of other images of the same meal.
    pub other_image_urls: Vec<String>,
    /// Reason why image was accepted (e.g., from AI).
    pub approval_message: Option<String>,
}

/// This struct contains all environmental information. co2 in grams, water in litres
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EnvironmentInfo {
    /// The average environmental rating. Out of `max_rating`
    pub average_rating: u32,
    /// The number of stars the food has for CO2 emmissions. Out of `max_rating`
    pub co2_rating: u32,
    /// The amount of CO2 emitted by the production of the food. In grams
    pub co2_value: u32,
    /// The number of stars the food has for water consumption. Out of `max_rating`
    pub water_rating: u32,
    /// The amount of water used for the production of the food. In Millilitres
    pub water_value: u32,
    /// The number of stars the food has for animal welfare. Out of `max_rating`
    pub animal_welfare_rating: u32,
    /// The number of stars the food has for rainforest preservation. Out of `max_rating`
    pub rainforest_rating: u32,
    /// The maximum amount of stars for each category
    pub max_rating: u32,
}
