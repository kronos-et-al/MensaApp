use async_graphql::SimpleObject;

use crate::{interface::persistent_data::model, util};

/// This struct contains all environmental information. co2 in grams, water in litres
#[derive(Debug, SimpleObject)]
pub(in super::super) struct EnvironmentInfo {
    /// The average environmental rating. Out of `max_rating`
    average_rating: u32,
    /// The number of stars the food has for CO2 emmissions. Out of `max_rating`
    co2_rating: u32,
    /// The amount of CO2 emitted by the production of the food. In grams
    co2_value: u32,
    /// The number of stars the food has for water consumption. Out of `max_rating`
    water_rating: u32,
    /// The amount of water used for the production of the food. In Millilitres
    water_value: u32,
    /// The number of stars the food has for animal welfare. Out of `max_rating`
    animal_welfare_rating: u32,
    /// The number of stars the food has for rainforest preservation. Out of `max_rating`
    rainforest_rating: u32,
    /// The maximum amount of stars for each category
    max_rating: u32,
}

impl From<model::EnvironmentInfo> for EnvironmentInfo {
    fn from(value: model::EnvironmentInfo) -> Self {
        Self {
            average_rating: value.average_rating,
            co2_rating: value.co2_rating,
            co2_value: value.co2_value,
            water_rating: value.water_rating,
            water_value: value.water_value,
            animal_welfare_rating: value.animal_welfare_rating,
            rainforest_rating: value.rainforest_rating,
            max_rating: value.max_rating,
        }
    }
}

/// The nutrients of a dish
#[derive(Debug, SimpleObject)]
pub(in super::super) struct NutritionData {
    /// Energy in Kcal
    energy: u32,
    /// Protein in grams
    protein: u32,
    /// Carbs in grams
    carbohydrates: u32,
    /// Sugar in grams
    sugar: u32,
    /// Fat in grams
    fat: u32,
    /// Saturated fat in grams
    saturated_fat: u32,
    /// Salt in grams
    salt: u32,
}

impl From<util::NutritionData> for NutritionData {
    fn from(value: util::NutritionData) -> Self {
        Self {
            energy: value.energy,
            protein: value.protein,
            carbohydrates: value.carbohydrates,
            sugar: value.sugar,
            fat: value.fat,
            saturated_fat: value.saturated_fat,
            salt: value.salt,
        }
    }
}
