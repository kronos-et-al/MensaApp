use std::collections::HashMap;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::util::Date;
use async_trait::async_trait;
use crate::layer::data::swka_parser::html_parser::HTMLParser;
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::layer::data::swka_parser::swka_resolver::SwKaResolver;

pub struct SwKaParseManager;


impl SwKaParseManager {
    pub fn new() -> SwKaParseManager {
        Self
    }

    /// Sorts all canteens by days and urls in a hashmap.
    async fn parse_and_sort_canteens_by_days(&self, urls: Vec<String>) -> HashMap<Date, Vec<ParseCanteen>> {
        let mut map: HashMap<Date, Vec<ParseCanteen>> = HashMap::new();

        let resolver = SwKaResolver;

        let htmls = resolver.get_htmls(urls).await;

        // TODO unwrap()
        for html in htmls.unwrap() {
            for (date, canteen) in HTMLParser::transform(&html).expect("HELP!") {
                map.entry(date).or_default().push(canteen);
            }
        }
        map
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager {

    // TODO needs validation
    async fn parse(&self, day: Date) -> Vec<ParseCanteen> {

        let mut map = self.parse_and_sort_canteens_by_days(SwKaLinkCreator::get_urls(day)).await;

        map.remove(&day).unwrap_or_default()
    }

    // TODO needs validation
    async fn parse_all(&self) -> Vec<(Date, Vec<ParseCanteen>)> {
        let map = self.parse_and_sort_canteens_by_days(SwKaLinkCreator::get_all_urls()).await;

        map.into_iter().collect()
    }
}