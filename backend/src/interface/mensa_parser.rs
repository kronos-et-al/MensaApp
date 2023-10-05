//! This interface allows the reading of menus from an external source.
pub mod model;

use crate::{interface::mensa_parser::model::ParseCanteen, util::Date};
use async_trait::async_trait;
use thiserror::Error;

/// Result returned from parse operations, potentially containing a [`ParseError`].
pub type Result<T> = std::result::Result<T, ParseError>;

/// Error indicating that something went wrong while parsing.
#[derive(Debug, Error)]
pub enum ParseError {
    /// A html node was expected but not found in the document.
    #[error("the node was not found: {0}")]
    InvalidHtmlDocument(String),
    /// No connection to the meal plan webpage could be established
    #[error("no connection could be established: {0}")]
    NoConnectionEstablished(String),
    //todo! Improve error message & check occurence.
    /// Html document could not be decoded.
    #[error("some html code couldn't be decoded: {0}")]
    DecodeFailed(String),
    /// Could not build client for making web requests.
    #[error("the html reqwest client creation failed: {0}")]
    ClientBuilderFailed(String),
}

#[async_trait]
/// Parser interface. Provides functions which return canteen structs. Canteen structs contain raw data obtained by parsing mealplans.
pub trait MealplanParser: Send + Sync {
    /// Initiate a parse procedure. Returns a canteen struct containing meal plan data of the given date.
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>>;
    /// Initiate a parse procedure. Returns a tuple containing meal plan data of the next four weeks. The tuple contains a canteen struct with the related date.
    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>>;
}
