//! These structs are used for parse operations.

use crate::util::{Additive, Allergen, MealType, Price};

/// Canteen struct containing all meal plan information of a canteen. Contains raw data.
#[derive(Debug)]
pub struct ParseCanteen {
    /// Name of the canteen.
    pub name: String,
    /// All the [lines](ParseLine) situated within the canteen.
    pub lines: Vec<ParseLine>,
    /// Position/Ranking of the canteen
    pub pos: u32
}

/// Line struct containing all information of a line and their meals. Contains raw data.
#[derive(Debug)]
pub struct ParseLine {
    /// Name of the line.
    pub name: String,
    /// All [dishes](Dish) served at this [canteen](ParseCanteen) at a particular day.
    pub dishes: Vec<Dish>,
    /// Position/Ranking of the line
    pub pos: u32
}

/// Dish struct containing all information of a meal or side.
#[derive(Debug)]
pub struct Dish {
    /// Name of the dish.
    pub name: String,
    /// Price of the meal for students, employees, guests and pupils. See [Price].
    pub price: Price,
    /// All containing allergens. See [Allergen]
    pub allergens: Vec<Allergen>,
    /// All containing additives. See [Additive]
    pub additives: Vec<Additive>,
    /// Meal-Type of the dish. See [MealType]
    pub meal_type: MealType,
    /// The environmental score of the dish, which is an integer between 0 and 3. (Higher is better) 0 indicates that no score was present.
    pub env_score: u32,
}
