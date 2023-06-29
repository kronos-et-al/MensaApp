//! These structs are used for parse operations.

use crate::util::{Additive, Allergen, MealType, Price};

/// Canteen-Struct containing all mealplan information of an canteen. Contains raw data.
pub struct ParseCanteen {
    /// Name of the canteen.
    pub name: String,
    /// All related lines.
    pub lines: Vec<ParseLine>,
}

/// Line-Struct containing all information of an line and their meals. Contains raw data.
pub struct ParseLine {
    /// Name of the line.
    pub name: String,
    /// All related dishes.
    pub dishes: Vec<Dish>,
}

/// Dish-Struct containing all information of a meal or side.
pub struct Dish {
    /// Name of the dish.
    pub name: String,
    /// Price of the meal for students, employees, guests and pupils.
    pub price: Price,
    /// All containing allergens.
    pub allergens: Vec<Allergen>,
    /// All containing additives.
    pub additives: Vec<Additive>,
    /// Meal-Type of the dish.
    pub c_type: MealType,
}
