//! This interface allows the reading of menus from an external source.
pub mod model;

use crate::{interface::mensa_parser::model::ParseCanteen, util::Date};
use async_trait::async_trait;

#[async_trait]
/// Parser interface. Provides functions which return canteen structs. Canteen structs contain raw data obtained by parsing mealplans.
pub trait MealplanParser {
    /// Initiate a parse procedure. Returns a canteen struct containing mealplan data of the given date.
    async fn parse(&self, day: Date) -> Vec<ParseCanteen>;
    /// Initiate a parse procedure. Returns a tuple containing mealplan data of the next four weeks. The tuple contains a canteen struct with the related date.
    async fn parse_all(&self) -> Vec<(Date, Vec<ParseCanteen>)>;
}
