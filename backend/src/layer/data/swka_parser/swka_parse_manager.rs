//! The [`SwKaManager`] calls and transfers data between related classes.

use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::mensa_parser::{MealplanParser, ParseError, ParseInfo};
use crate::layer::data::swka_parser::html_parser::HTMLParser;
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::layer::data::swka_parser::swka_resolver::SwKaResolver;
use crate::util::Date;
use async_trait::async_trait;
use std::collections::HashMap;

pub struct SwKaParseManager {
    parse_info: ParseInfo,
}

impl SwKaParseManager {
    #[must_use]
    pub const fn new(parse_info: ParseInfo) -> Self {
        Self { parse_info }
    }

    /// Sorts all canteens by days and urls in a hashmap.<br>
    /// [`ParseCanteen`]s are grouped for each [`Date`].
    async fn parse_and_sort_canteens_by_days(
        &self,
        urls: Vec<String>,
    ) -> Result<HashMap<Date, Vec<ParseCanteen>>, ParseError> {
        let mut map: HashMap<Date, Vec<ParseCanteen>> = HashMap::new();

        for html in self.get_resolver().get_html_strings(urls).await? {
            for (date, canteen) in HTMLParser::transform(&html)? {
                map.entry(date).or_default().push(canteen);
            }
        }
        Ok(map)
    }

    fn get_link_creator(&self) -> SwKaLinkCreator {
        SwKaLinkCreator::new(
            self.parse_info.base_url.clone(),
            self.parse_info.valid_canteens.clone(),
        )
    }

    fn get_resolver(&self) -> SwKaResolver {
        SwKaResolver::new(
            self.parse_info.client_timeout,
            self.parse_info.client_user_agent.clone(),
        )
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager {
    /// This method handles the parsing procedure for the given day.
    /// To obtain the requested canteens, the manager calls [`SwKaLinkCreator`] to create urls for the meal plans.
    /// The [`SwKaResolver`] loads the html code of the given website behind the urls.
    /// At least the [`HTMLParser`] interprets the html code into [`ParseCanteen`] objects.
    /// These objects will be returned.<br>
    /// `day: Date`<br>
    /// The day this function looks for meal plans.<br>
    /// ## Return
    /// All [`ParseCanteen`]s containing meal plan data for the given day or an error if something in the chain above fails.
    async fn parse(&self, day: Date) -> Result<Vec<ParseCanteen>, ParseError> {
        let mut map = self
            .parse_and_sort_canteens_by_days(self.get_link_creator().get_urls(day))
            .await?;

        Ok(map.remove(&day).unwrap_or_default())
    }

    /// This method handles the parsing procedure for each day in the next four weeks.
    /// To obtain the requested canteens, the manager calls [`SwKaLinkCreator`] to create urls for the meal plans.
    /// The [`SwKaResolver`] loads the html code of the given website behind the urls.
    /// At least the [`HTMLParser`] interprets the html code into [`ParseCanteen`] objects.
    /// These objects will be returned.<br>
    /// ## Return
    /// All [`ParseCanteen`]s grouped by their [`Date`] or an error if something in the chain above fails.
    async fn parse_all(&self) -> Result<Vec<(Date, Vec<ParseCanteen>)>, ParseError> {
        let map = self
            .parse_and_sort_canteens_by_days(self.get_link_creator().get_all_urls())
            .await?;

        Ok(map.into_iter().collect())
    }
}

#[cfg(test)]
mod test {
    use crate::layer::data::swka_parser::swka_parse_manager::SwKaParseManager;
    use crate::layer::data::swka_parser::util;

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
    async fn sort_and_parse_canteens_with_valid_urls() {
        let manager = SwKaParseManager::new(util::get_parse_info());
        let result = manager
            .parse_and_sort_canteens_by_days(get_valid_urls())
            .await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn sort_and_parse_canteens_with_invalid_urls() {
        let manager = SwKaParseManager::new(util::get_parse_info());
        let mut urls = get_valid_urls();
        urls.push(String::from("invalid"));
        let result = manager.parse_and_sort_canteens_by_days(urls).await;
        assert!(result.is_err());
    }
}
