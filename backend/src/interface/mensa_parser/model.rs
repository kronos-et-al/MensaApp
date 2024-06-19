//! These structs are used for parse operations.

use crate::util::{Additive, Allergen, FoodType, NutritionData, Price};

/// Canteen struct containing all meal plan information of a canteen. Contains raw data.
#[derive(Debug)]
pub struct ParseCanteen {
    /// Name of the canteen.
    pub name: String,
    /// All the [lines](ParseLine) situated within the canteen.
    pub lines: Vec<ParseLine>,
    /// Position/Ranking of the canteen
    pub pos: u32,
}

/// Line struct containing all information of a line and their meals. Contains raw data.
#[derive(Debug)]
pub struct ParseLine {
    /// Name of the line.
    pub name: String,
    /// All [dishes](Dish) served at this [canteen](ParseCanteen) at a particular day.
    pub dishes: Vec<Dish>,
    /// Position/Ranking of the line
    pub pos: u32,
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
    /// Meal-Type of the dish. See [`FoodType`]
    pub food_type: FoodType,
    /// The environmental score of the dish. See [`ParseEnvironmentInfo`]
    pub env_score: Option<ParseEnvironmentInfo>,
    /// The nutritional information of the dish
    pub nutrition_data: Option<NutritionData>,
}

/// This struct contains all environmental information. co2 in grams, water in litres
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParseEnvironmentInfo {
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
