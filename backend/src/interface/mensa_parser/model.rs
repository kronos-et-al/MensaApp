//! These structs are used for parse operations.

use std::fmt::Display;

use crate::util::{Additive, Allergen, MealType, Price};

/// Canteen-Struct containing all mealplan information of an canteen. Contains raw data.
pub struct ParseCanteen {
    /// Name of the canteen.
    pub name: String,
    /// All related lines.
    pub lines: Vec<ParseLine>,
}

impl Display for ParseCanteen {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut lines = String::new();
        for line in &self.lines {
            lines.push_str(&format!("{line}\n"));
        }
        write!(f, "{}\n{lines}", self.name)
    }
}
/// Line-Struct containing all information of an line and their meals. Contains raw data.
pub struct ParseLine {
    /// Name of the line.
    pub name: String,
    /// All related dishes.
    pub dishes: Vec<Dish>,
}

impl Display for ParseLine {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut dishes = String::new();
        for dish in &self.dishes {
            dishes.push_str(&format!("{dish}\n"));
        }
        write!(f, "{}\n\n{dishes}", self.name)
    }
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
    pub meal_type: MealType,
    /// Determines if this dish is a side or a meal.
    pub is_side: bool,
    /// Environmental_score given by the swka.
    pub env_score: u32,
}

impl Display for Dish {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut allergens = if self.allergens.is_empty() {
            String::new()
        } else {
            String::from("Allergens: ")
        };
        for allergen in &self.allergens {
            allergens.push_str(&format!("{allergen}, "));
        }

        let mut additives = if self.additives.is_empty() {
            String::new()
        } else {
            String::from("Additives: ")
        };
        for additive in &self.additives {
            additives.push_str(&format!("{additive}, "));
        }

        write!(
            f,
            "{}\n{}\n{}{}{} Is side: {}, Environment score: {}\n",
            self.name,
            self.price,
            allergens,
            additives,
            self.meal_type,
            self.is_side,
            self.env_score
        )
    }
}
