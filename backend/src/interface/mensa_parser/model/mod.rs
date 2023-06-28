//! These structs are used for parse operations

use crate::util::{Additive, Allergen, MealType};

/// Canteen-Struct containing all mealplan information of an canteen. Contains raw data.
pub struct ParseCanteen {
    /// Name of the canteen.
    name: String,
    /// All related lines.
    lines: Vec<ParseLine>
}
/// Line-Struct containing all information of an line and their meals. Contains raw data.
pub struct ParseLine {
    /// Name of the line.
    name: String,
    /// All related dishes.
    dishes: Vec<Dish>
}
/// Dish-Struct containing all information of a meal or side.
pub struct Dish {
    /// Name of the dish.
    name: String,
    /// Price of the dish for students, employees, guests and pupils.
    price_student: u32,
    price_employee: u32,
    price_guest: u32,
    price_pupil: u32,
    /// All containing allergens.
    allergens: Vec<Allergen>,
    /// All containing additives.
    additives: Vec<Additive>,
    /// Meal-Type of the dish.
    c_type: MealType

}
