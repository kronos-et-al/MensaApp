use std::collections::HashMap;
use std::hash::Hasher;
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

    // Sorts all canteens by days and urls in a hashmap.
    fn parse_and_sort_canteens_by_days(&self, urls: Vec<String>) -> HashMap<Date, Vec<ParseCanteen>> {
        let mut map = HashMap::new();

        let resolver = SwKaResolver;
        let parser = HTMLParser;

        let mut htmls = resolver.get_htmls(urls);

        for html in htmls {
            for (date, canteen) in parser.transform(html) {
                map = self.push_into_map(map, date, canteen);
            }
        }
        map
    }

    // Inserts an element into the HashMap. Checks if Vec<ParseCanteen> exists.
    fn push_into_map(mut map: HashMap<Date, Vec<ParseCanteen>>, key: Date, val: ParseCanteen) -> HashMap<Date, Vec<ParseCanteen>>{
        let tmp_val = map.get(&key);
        if tmp_val.is_some() {
            tmp_val.unwrap().push(val);
        } else {
            map.insert(date, vec![val]);
        }
        map
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager{

    // TODO needs validation
    async fn parse(&self, day: Date) -> Vec<ParseCanteen> {
        let mut map = HashMap::new();
        let link_creator = SwKaLinkCreator;

        map = self.parse_and_sort_canteens_by_days(link_creator.get_urls(&day));

        let mut canteens = Vec::new();
        let tmp: Vec<ParseCanteen> = *map.get(&day);

        if tmp.is_some() {
            canteens = tmp.unwrap().clone();
        }

        canteens
    }

    // TODO needs validation
    async fn parse_all(&self) -> Vec<(Date, Vec<ParseCanteen>)> {
        let mut map = HashMap::new();
        let mut res = Vec::new();
        let link_creator = SwKaLinkCreator;

        map = self.parse_and_sort_canteens_by_days(link_creator.get_all_urls());

        let mut keys: Vec<Date> = map.into_keys().collect();

        for key in keys {
            res.push((key, *map.get(&key)))
        }

        res
    }
}