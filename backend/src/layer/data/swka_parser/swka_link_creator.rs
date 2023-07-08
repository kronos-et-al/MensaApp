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
    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-115/SwKaLinkCreator> for more information

    pub const fn new() -> Self {
        Self
    }

    pub fn get_urls(&self, day: &Date) -> Vec<String> {
        let calender_week = Self::get_calender_week(*day);
        let mut urls = Vec::new();
        for mensa in MENSA_NAMES {
            urls.push(format!(
                "{BASE_URL}{mensa}{URL_SEPARATOR}{WEEK_SELECTOR}{calender_week}"
            ));
        }
        urls
    }

    pub fn get_all_urls(&self) -> Vec<String> {
        let today = Self::get_todays_date();
        let mut all_urls = Vec::new();
        for i in 0..NUMBER_OF_WEEKS_TO_POLL {
            let day = today.checked_add_days(Days::new(i * NUMBER_OF_DAYS_PER_WEEK)).expect(PARSE_E_MSG);
            all_urls.append(&mut self.get_urls(&day));
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
    use crate::{layer::data::swka_parser::swka_link_creator::SwKaLinkCreator};

    #[tokio::test]
    async fn test_url() {
        let link_creator = SwKaLinkCreator::new();
        for link in link_creator.get_all_urls() {
            println!("{link}");
        }
    }
}
