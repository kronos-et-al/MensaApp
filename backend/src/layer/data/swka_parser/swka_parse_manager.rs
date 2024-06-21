//! The [`SwKaParseManager`] calls and transfers data between related classes.

use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::mensa_parser::{MealplanParser, ParseError};
use crate::layer::data::swka_parser::html_parser::HTMLParser;
use crate::layer::data::swka_parser::swka_html_request::SwKaHtmlRequest;
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::util::Date;
use async_trait::async_trait;
use std::collections::HashMap;

/// Struct containing all information necessary to create a [`SwKaParseManager`].
#[derive(Debug, Clone)]
pub struct SwKaInfo {
    /// Base url under which the canteens' meal plans are available.
    pub base_url: String,
    /// Canteen slugs to be appended to the base url.
    pub valid_canteens: Vec<String>,
    /// Timeout when making web requests.
    pub client_timeout: std::time::Duration,
    /// User agent string when making web request.
    pub client_user_agent: String,
    /// Number of weeks in the future to request data for on full parsing.
    pub number_of_weeks_to_poll: u32,
}

/// Class for managing the request and parsing of meal plans.
#[derive(Debug)]
pub struct SwKaParseManager {
    link_creator: SwKaLinkCreator,
    request: SwKaHtmlRequest,
    html_parser: HTMLParser,
}

impl SwKaParseManager {
    /// Method for creating a [`SwKaParseManager`] instance.
    /// # Errors
    /// If the request client creation fails an error 'll be returned.
    pub fn new(parse_info: SwKaInfo) -> Result<Self, ParseError> {
        Ok(Self {
            link_creator: SwKaLinkCreator::new(
                parse_info.base_url.clone(),
                parse_info.valid_canteens.clone(),
                parse_info.number_of_weeks_to_poll,
            ),
            request: SwKaHtmlRequest::new(parse_info.client_timeout, parse_info.client_user_agent)?,
            html_parser: HTMLParser,
        })
    }

    /// Sorts all canteens by days and urls in a hashmap.<br>
    /// [`ParseCanteen`]s are grouped for each [`Date`].
    async fn parse_and_sort_canteens_by_days(
        &self,
        urls: Vec<String>,
    ) -> Result<HashMap<Date, Vec<ParseCanteen>>, ParseError> {
        let mut map: HashMap<Date, Vec<ParseCanteen>> = HashMap::new();

        for (position, html) in self
            .request
            .get_html_strings(urls)
            .await?
            .iter()
            .enumerate()
        {
            for (date, canteen) in self.html_parser.transform(
                html,
                u32::try_from(position).expect("u32 could not be casted from usize"),
            )? {
                map.entry(date).or_default().push(canteen);
            }
        }
        Ok(map)
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager {
    /// This method handles the parsing procedure for the given day.
    /// To obtain the requested canteens, the manager calls [`SwKaLinkCreator`] to create urls for the meal plans.
    /// The [`SwKaHtmlRequest`] loads the html code of the given website behind the urls.
    /// At least the [`HTMLParser`] interprets the html code into [`ParseCanteen`] objects.
    /// These objects will be returned.<br>
    /// `day: Date`<br>
    /// The day this function looks for meal plans.<br>
    /// ## Return
    /// All [`ParseCanteen`]s containing meal plan data for the given day or an error if something in the chain above fails.
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>, ParseError> {
        let mut map = self
            .parse_and_sort_canteens_by_days(self.link_creator.get_urls(day))
            .await?;

        Ok(map.remove(&day).unwrap_or_default())
    }

    /// This method handles the parsing procedure for each day in the next four weeks.
    /// To obtain the requested canteens, the manager calls [`SwKaLinkCreator`] to create urls for the meal plans.
    /// The [`SwKaHtmlRequest`] loads the html code of the given website behind the urls.
    /// At least the [`HTMLParser`] interprets the html code into [`ParseCanteen`] objects.
    /// These objects will be returned.<br>
    /// ## Return
    /// All [`ParseCanteen`]s grouped by their [`Date`] or an error if something in the chain above fails.
    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>, ParseError> {
        let map = self
            .parse_and_sort_canteens_by_days(self.link_creator.get_all_urls())
            .await?;

        Ok(map.into_iter().collect())
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]

    use crate::interface::mensa_parser::MealplanParser;
    use crate::layer::data::swka_parser::swka_parse_manager::SwKaParseManager;
    use crate::layer::data::swka_parser::test::const_test_data as test_util;
    use chrono::Local;

    fn get_valid_urls() -> Vec<String> {
        vec![
            String::from(
                "https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/mensa_adenauerring/",
            ),
            String::from(
                "https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/mensa_erzberger/",
            ),
        ]
    }

    #[tokio::test]
    async fn test_sort_and_parse_canteens_with_valid_urls() {
        let manager = SwKaParseManager::new(test_util::get_parse_info()).unwrap();
        let result = manager
            .parse_and_sort_canteens_by_days(get_valid_urls())
            .await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_sort_and_parse_canteens_with_invalid_urls() {
        let manager = SwKaParseManager::new(test_util::get_parse_info()).unwrap();
        let mut urls = get_valid_urls();
        urls.push(String::from("invalid"));
        let result = manager.parse_and_sort_canteens_by_days(urls).await;
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_parse() {
        let manager = SwKaParseManager::new(test_util::get_parse_info()).unwrap();
        assert!(manager.parse(Local::now().date_naive()).await.is_ok());
    }

    #[tokio::test]
    async fn test_parse_all() {
        let manager = SwKaParseManager::new(test_util::get_parse_info()).unwrap();
        assert!(manager.parse_all().await.is_ok());
    }
}
