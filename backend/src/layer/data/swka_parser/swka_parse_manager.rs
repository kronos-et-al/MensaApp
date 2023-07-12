use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::mensa_parser::MealplanParser;
use crate::layer::data::swka_parser::html_parser::{HTMLParser, ParseError};
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::layer::data::swka_parser::swka_resolver::SwKaResolver;
use crate::util::Date;
use async_trait::async_trait;
use std::collections::HashMap;

pub struct SwKaParseManager;

impl SwKaParseManager {
    pub const fn _new() -> Self {
        Self
    }

    /// Sorts all canteens by days and urls in a hashmap.
    async fn parse_and_sort_canteens_by_days(
        &self,
        urls: Vec<String>,
    ) -> Result<HashMap<Date, Vec<ParseCanteen>>, ParseError> {
        let mut map: HashMap<Date, Vec<ParseCanteen>> = HashMap::new();

        for html in SwKaResolver::new().get_html_strings(urls).await? {
            for (date, canteen) in HTMLParser::transform(&html)? {
                map.entry(date).or_default().push(canteen);
            }
        }
        Ok(map)
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager {
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>, ParseError> {
        let mut map = self
            .parse_and_sort_canteens_by_days(SwKaLinkCreator::get_urls(day))
            .await?;

        Ok(map.remove(&day).unwrap_or_default())
    }

    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>, ParseError> {
        let map = self
            .parse_and_sort_canteens_by_days(SwKaLinkCreator::get_all_urls())
            .await?;

        Ok(map.into_iter().collect())
    }
}
