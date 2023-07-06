use crate::interface::mensa_parser::MealplanParser;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::model::Canteen;
use crate::util::Date;
use async_trait::async_trait;
use chrono::Datelike;
use crate::layer::data::swka_parser::html_parser::HTMLParser;
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::layer::data::swka_parser::swka_resolver::SwKaResolver;

pub struct SwKaParseManager;


impl SwKaParseManager {
    pub fn new() -> SwKaParseManager {
        Self
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager{

    async fn parse(&self, day: Date) -> Vec<ParseCanteen> {
        let link_creator = SwKaLinkCreator;
        let parser = HTMLParser;
        let resolver = SwKaResolver;

        // Get urls from link_creator. Get html from resolver.
        let mut htmls = resolver.get_htmls(link_creator.get_urls(&day));
        let mut results = Vec::new();
        let i = htmls.len();

        // Parse all htmls into results (Vec<Date, ParseCanteen)>)
        for _ in [1..i] {
            let html = htmls.pop();
            if html.is_some() {
                results.push(parser.transform(html.unwrap()));
            }
        }
        // Collect canteens, which are related to day
        let mut canteens = Vec::new();
        for x in results {
            for (date, canteen) in x {
                // Check if date is equal to param day
                if date.day() == day.day()
                    && date.month() == day.month()
                    && date.year() == day.year() {
                    canteens.push(canteen);
                }
            }
        }
        // Return of all canteens related to date "day"
        canteens
    }
    //TODO Impl parse_all() -> Vec<(Date, Vec<Canteen>)>
    async fn parse_all(&self) -> Vec<(Date, Vec<ParseCanteen>)> {
        todo!()
    }
}