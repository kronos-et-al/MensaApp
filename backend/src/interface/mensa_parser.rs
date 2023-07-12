//! This interface allows the reading of menus from an external source.
pub mod model;

use crate::layer::data::swka_parser::html_parser::ParseError;
use crate::{interface::mensa_parser::model::ParseCanteen, util::Date};
use async_trait::async_trait;

#[async_trait]
/// Parser interface. Provides functions which return canteen structs. Canteen structs contain raw data obtained by parsing mealplans.
pub trait MealplanParser {
    /// Initiate a parse procedure. Returns a canteen struct containing meal plan data of the given date.
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>, ParseError>;
    /// Initiate a parse procedure. Returns a tuple containing meal plan data of the next four weeks. The tuple contains a canteen struct with the related date.
    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>, ParseError>;
}
