//! A module for creating links to the html files of the website of the Studierendenwerk Karlsruhe (www.sw-ka.de)
//! The basic structure of a link is as follows:
//! 
//! [`BASE_URL`]+[`MENSA_NAMES`]+[`URL_SEPARATOR`]+[`WEEK_SELECTOR`]+number
//! 
//! Like this for example: 
//! 
//! <https://www.sw-ka.de/en/hochschulgastronomie/speiseplan/mensa_adenauerring/?kw=28>

use chrono::{Datelike, Days, Local};

use crate::util::Date;

const MENSA_NAMES: [&str; 7] = [
    "mensa_adenauerring",
    "mensa_gottesaue",
    "mensa_moltke",
    "mensa_x1moltkestrasse",
    "mensa_erzberger",
    "mensa_tiefenbronner",
    "mensa_holzgarten",
];
const BASE_URL: &str = "https://www.sw-ka.de/en/hochschulgastronomie/speiseplan/";
const URL_SEPARATOR: char = '/';
const WEEK_SELECTOR: &str = "?kw=";
const NUMBER_OF_WEEKS_TO_POLL: u64 = 4;
const NUMBER_OF_DAYS_PER_WEEK: u64 = 7;

const PARSE_E_MSG: &str = "Error while parsing";

pub struct SwKaLinkCreator;

impl SwKaLinkCreator {
    pub fn get_urls(day: Date) -> Vec<String> {
        let calender_week = Self::get_calender_week(day);
        let mut urls = Vec::new();
        for mensa in MENSA_NAMES {
            urls.push(format!(
                "{BASE_URL}{mensa}{URL_SEPARATOR}{WEEK_SELECTOR}{calender_week}"
            ));
        }
        urls
    }

    pub fn get_all_urls() -> Vec<String> {
        let today = Self::get_todays_date();
        Self::get_all_urls_for_next_weeks_from_date(today)
    }

    fn get_all_urls_for_next_weeks_from_date(date: Date) -> Vec<String> {
        let mut all_urls = Vec::new();
        for i in 0..NUMBER_OF_WEEKS_TO_POLL {
            let day = date.checked_add_days(Days::new(i * NUMBER_OF_DAYS_PER_WEEK)).expect(PARSE_E_MSG);
            all_urls.append(&mut Self::get_urls(day));
        }
        all_urls
    }

    fn get_calender_week(day: Date) -> u32 {
        day.iso_week().week()
    }

    fn get_todays_date() -> Date {
        Local::now().date_naive()
    }
}

#[cfg(test)]
mod tests {
    use std::{fs::{self, File}, io::Write};

    use crate::{layer::data::swka_parser::swka_link_creator::SwKaLinkCreator, util::Date};

    #[tokio::test]
    async fn test_get_urls() {
        let date = Date::from_ymd_opt(2023, 7, 10);
        assert!(date.is_some());
        let date = date.expect("This case should never occur");
        let result = SwKaLinkCreator::get_urls(date);
        let expected = read_from_file("src/layer/data/swka_parser/tests/test_urls_single.txt");
        assert!(expected.is_ok());
        let expected = expected.expect("This case should never occur");
        assert_eq!(format!("{result:#?}"), expected);
    }

    #[tokio::test]
    async fn test_get_all_urls() {
        let date = Date::from_ymd_opt(2023, 7, 10);
        assert!(date.is_some());
        let date = date.expect("This case should never occur");
        let result = SwKaLinkCreator::get_all_urls_for_next_weeks_from_date(date);
        let expected = read_from_file("src/layer/data/swka_parser/tests/test_urls_all.txt");
        assert!(expected.is_ok());
        let expected = expected.expect("This case should never occur");
        assert_eq!(format!("{result:#?}"), expected);
    }

    #[allow(dead_code)]
    fn write_output_to_file(path: &str, data: &[String]) -> std::io::Result<()>{
        let mut output = File::create(path)?;
        write!(output, "{data:#?}")
    }

    fn read_from_file(path: &str) -> std::io::Result<String> {
        fs::read_to_string(path)
    }
}
