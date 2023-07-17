//! This interface allows the reading of menus from an external source.
pub mod model;

use crate::{interface::mensa_parser::model::ParseCanteen, util::Date};
use async_trait::async_trait;
use thiserror::Error;

#[derive(Debug)]
pub struct ParseInfo {
    pub base_url: &'static str,
    pub valid_canteens: Vec<&'static str>,
    pub client_timeout: std::time::Duration,
    pub client_user_agent: String
}



#[derive(Debug, Error)]
pub enum ParseError {
    #[error("the node was not found: {0}")]
    InvalidHtmlDocument(&'static str),
    #[error("no connection could be established")]
    NoConnectionEstablished,
    #[error("some html code couldn't be decoded")]
    DecodeFailed,
    #[error("the html reqwest client creation failed")]
    ClientBuilderFailed,
}
#[async_trait]
/// Parser interface. Provides functions which return canteen structs. Canteen structs contain raw data obtained by parsing meal plans.
pub trait MealplanParser {
    /// Initiate a parse procedure. Returns a canteen struct containing meal plan data of the given date.
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>, ParseError>;
    /// Initiate a parse procedure. Returns a tuple containing meal plan data of the next four weeks. The tuple contains a canteen struct with the related date.
    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>, ParseError>;
}
