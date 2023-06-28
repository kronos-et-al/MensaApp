//! This interface allows the reading of menus from an external source.
use chrono::{DateTime, Local};
use crate::interface::mensa_parser::model::ParseCanteen;
use async_trait::async_trait;

mod model;

#[async_trait] /// Parser interface. Provides functions which return canteen structs. Canteen structs contain raw data obtained by parsing mealplans.
pub trait MealplanParser {
    /// Initiate a parse procedure. Returns a canteen struct containing mealplan data of the given date.
    async fn parse(day: DateTime<Local>) -> Vec<ParseCanteen>;
    /// Initiate a parse procedure. Returns a tuple containing mealplan data of the next four weeks. The tuple contains a canteen struct with the related date.
    async fn parse_all() -> (DateTime<Local>, Vec<ParseCanteen>);
}