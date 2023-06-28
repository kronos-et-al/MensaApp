//! The interfaces specified here allow access to data stored in a persistent datastore like a database.
use crate::interface::persistent_data::model::{Canteen, DataError, Line, Meal, Side};
use async_trait::async_trait;
use chrono::{DateTime, Local};
use uuid::Uuid;
use crate::util::{Additive, Allergen, MealType};

mod model;


#[async_trait] /// An interface for checking relations and inserting data structures. The MealplanManagement component uses this interface for database access.
pub trait MealplanManagementDataAccess {
    /// Determines all canteens with a similar name.
    async fn get_similar_canteens(similar_name: String) -> Result<Vec<Canteen>, DataError>;
    /// Determines all lines with a similar name.
    async fn get_similar_lines(similar_name: String) -> Result<Vec<Line>, DataError>;
    /// Determines all meals with a similar name.
    async fn get_similar_meals(similar_name: String) -> Result<Vec<Meal>, DataError>;
    /// Determines all sides with a similar name.
    async fn get_similar_sides(similar_name: String) -> Result<Vec<Side>, DataError>;

    /// Updates an existing canteen entity in the database. Returns the entity.
    async fn update_canteen(uuid: Uuid, name: String) -> Result<Canteen, DataError>;
    /// Updates an existing line entity in the database. Returns the entity.
    async fn update_line(uuid: Uuid, name: String) -> Result<Line, DataError>;
    /// Updates an existing meal entity in the database. Returns the entity.
    async fn update_meal(uuid: Uuid, line_id: Uuid, date: DateTime<Local>, name: String, price_student: u32, price_employee: u32, price_guest: u32, price_pupil: u32) -> Result<Meal, DataError>;
    /// Updates an existing side entity in the database. Returns the entity.
    async fn update_side(uuid: Uuid, line_id: Uuid, date: DateTime<Local>, name: String, price_student: u32, price_employee: u32, price_guest: u32, price_pupil: u32) -> Result<Side, DataError>;

    /// Adds a new canteen entity to the database. Returns the new entity.
    async fn insert_canteen(name: String) -> Result<Canteen, DataError>;
    /// Adds a new line entity to the database. Returns the new entity.
    async fn insert_line(name: String) -> Result<Line, DataError>;
    /// Adds a new meal entity to the database. Returns the new entity.
    async fn insert_meal(name: String, c_type: MealType, price_student: u32, price_employee: u32, price_guest: u32, price_pupil: u32, next_served: DateTime<Local>, allergens: Vec<Allergen>, additives: Vec<Additive>) -> Result<Meal, DataError>;
    /// Adds a new side entity to the database. Returns the new entity.
    async fn insert_side(name: String, c_type: MealType, price_student: u32, price_employee: u32, price_guest: u32, price_pupil: u32, next_served: DateTime<Local>, allergens: Vec<Allergen>, additives: Vec<Additive>) -> Result<Side, DataError>;
}