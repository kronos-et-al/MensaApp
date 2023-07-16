#![warn(missing_docs)]

//! The general structure of the html file is as follows: (// Are added comments)
//! ```html
//! <!-- ... -->
//! <!-- This is the root node identified by [ROOT_NODE_CLASS_SELECTOR] -->
//! <div class="main-content iwsetter">      
//!
//! <!-- ... -->
//!     <!-- This is the canteen name node identified by `CANTEEN_NAME_NODE_CLASS_SELECTOR` -->
//!     <!-- it contains the name of the canteen -->
//!     <h1 class="mensa_fullname">Dining Hall am Adenauerring</h1>
//! <!-- ... -->
//!     <!-- This is the super node of the day date node identified by -->
//!     <!--`DAY_DATE_SUPER_NODE_CLASS_SELECTOR` it contains several day nodes. See below: -->
//!     <ul class="canteen-day-nav">
//!     <!-- This is a day date node identified by `DAY_DATE_NODE_CLASS_SELECTOR` -->
//!     <!-- it contains an attribute identified by `DAY_DATE_ATTRIBUTE_NAME`, -->
//!     <!-- which contains the date -->
//!     <li>
//!         <a id="canteen_day_nav_1"
//!             rel="2023-07-10"
//!             href="javascript:;"onClick="setCanteenDate('2023-07-10');setCanteenDiv(1);">
//!             <span>Mo 10.07.</span>
//!         </a>
//!     </ul>
//! <!-- ... -->
//!     <!-- This is a day node identified by `DAY_NODE_CLASS_SELECTOR` -->
//!     <!-- it contains all of the lines (which contain dishes) for the day -->
//!     <div id="canteen_day_1" class="canteen-day">
//! <!-- ... -->
//!         <!-- This is a line node identified by `LINE_NODE_CLASS_SELECTOR` -->
//!         <!-- it contains all of the line information (name and dishes) -->
//!         <tr class="mensatype_rows">
//!             <!-- This is a line name node identified by `LINE_NAME_NODE_CLASS_SELECTOR` -->
//!             <!-- it contains the name of the line -->
//!             <td class="mensatype" style="white-space: normal !important;">
//!                 <div>Linie 1<br>Gut & Günstig</div>
//!             </td>
//! <!-- ... -->
//!             <!-- This is a dish node identified by -->
//!             <!-- `DISH_NODE_CLASS_SELECTOR+number between 0 and 8` -->
//!             <!-- it contains the dish information -->
//!             <tr class="mt-7">
//!                 <td class="mtd-icon">
//!                     <!-- This is a dish type node identified by `DISH_TYPE_NODE_CLASS_SELECTOR` -->
//!                     <!-- it contains an attribute called `DISH_TYPE_ATTRIBUTE_NAME`, -->
//!                     <!-- which contains the meal type -->
//!                     <div>
//!                         <img src="/layout/icons/vegetarisches-gericht.svg"
//!                         class="mealicon_2"
//!                         title="vegetarisches Gericht"><br>
//!                     </div>
//!                 </td>
//!                 <td class="first menu-title" id="menu-title-5240287810491942285">
//!                     <!-- This is the dish name node identified by `DISH_NAME_NODE_CLASS_SELECTOR` -->
//!                     <!-- it contains the name of the dish -->
//!                     <span onclick="toggleRating('5240287810491942285');" class="bg">
//!                         <b>2 Dampfnudeln mit Vanillesoße</b>
//!                     </span>
//!                     <!-- This is the dish info node identified by `DISH_INFO_NODE_CLASS_SELECTOR` -->
//!                     <!-- it contains the allergens and additives of the dish -->
//!                     <sup>[Ei,ML,We]</sup>
//!                 </td>
//!                 <td style="text-align: right;vertical-align:bottom;">
//!                     <!-- These are dish price nodes identified by `DISH_PRICE_NODE_CLASS_SELECTOR` -->
//!                     <!-- they contain the prices of the meal. -->
//!                     <!-- 1 = Student, 2 = Guest, 3 = Employee, 4 = Pupil -->
//!                     <span class="bgp price_1">3,20 &euro;</span>
//!                     <span class="bgp price_2">4,60 &euro;</span>
//!                     <span class="bgp price_3">4,20 &euro;</span>
//!                     <span class="bgp price_4">3,55 &euro;</span>
//!                     <div style="clear: both;"></div>
//!                     <a href="javascript:;"
//!                     title="&Oslash; Umwelt-Score"
//!                     onclick="toggleRating('5240287810491942285')">
//!                         <!-- This is the environment score node identified by -->
//!                         <!--`ENV_SCORE_NODE_CLASS_SELECTOR` it contains an attribute called -->
//!                         <!--`ENV_SCORE_ATTRIBUTE_NAME`, which contains the environment score -->
//!                         <div id="average-stars-1551112451474757280"
//!                             class="enviroment_score average" data-rating="3"
//!                             data-numstars="3"></div>
//!                     </a>
//!                 <tr>
//! <!-- ... -->
//! ```

use crate::interface::mensa_parser::{
    model::{Dish, ParseCanteen, ParseLine},
    ParseError,
};
use crate::util::{Additive, Allergen, Date, MealType, Price};
use regex::Regex;
use scraper::{ElementRef, Html, Selector};

const ROOT_NODE_CLASS_SELECTOR: &str = "div.main-content";
const CANTEEN_NAME_NODE_CLASS_SELECTOR: &str = "h1.mensa_fullname";

const DAY_DATE_SUPER_NODE_CLASS_SELECTOR: &str = "ul.canteen-day-nav";
const DAY_DATE_NODE_CLASS_SELECTOR: &str = "a";
const DAY_DATE_ATTRIBUTE_NAME: &str = "rel";
const DAY_NODE_CLASS_SELECTOR: &str = "div.canteen-day";

const LINE_NODE_CLASS_SELECTOR: &str = "tr.mensatype_rows";
const LINE_NAME_NODE_CLASS_SELECTOR: &str = "td.mensatype";

const DISH_NODE_CLASS_SELECTOR: &str = "tr.mt-";
const DISH_TYPE_NODE_CLASS_SELECTOR: &str = "img.mealicon_2";
const DISH_TYPE_ATTRIBUTE_NAME: &str = "title";
const DISH_NAME_NODE_CLASS_SELECTOR: &str = "span.bg";
const DISH_INFO_NODE_CLASS_SELECTOR: &str = "sup";
const DISH_PRICE_NODE_CLASS_SELECTOR: &str = "span.bgp.price_";
const ENV_SCORE_NODE_CLASS_SELECTOR: &str = "div.enviroment_score.average";
const ENV_SCORE_ATTRIBUTE_NAME: &str = "data-rating";

const DATE_FORMAT: &str = "%Y-%m-%d";
/// A Regex for getting prices in euros. A price consists of 1 or more digits, followed by a comma and then exactly two digits
const PRICE_REGEX: &str = r"([0-9]*),([0-9]{2})";
/// A Regex for getting allergens. An allergen consists of a single Uppercase letter followed by one or more upper- or lowercase letters (indicated by \w+)
const ALLERGEN_REGEX: &str = r"[A-Z]\w+";
/// A regex for getting additives. An additive consists of one or more digits
const ADDITIVE_REGEX: &str = r"[0-9]{1,2}";

const NUMBER_OF_MEAL_TYPES: u32 = 8;

const SELECTOR_PARSE_E_MSG: &str = "Error while parsing Selector string";
const REGEX_PARSE_E_MSG: &str = "Error while parsing regex string";

/// A static class, that transforms html files into datatypes, that can be used for further processing using the `HTMLParser::transform` function.
pub struct HTMLParser;

impl HTMLParser {
    /// Transforms an html document into a vector containing tuples of `Date` and `ParseCanteens`
    ///
    /// # Arguments
    ///
    /// * `html` - The contents of the html file to be parsed
    ///
    /// # Examples
    ///
    /// ```
    /// use crate::mensa_app_backend::layer::data::swka_parser::html_parser::HTMLParser;
    /// let canteen_data = HTMLParser::transform(include_str!("./test_data/test_normal.html"));
    /// ```
    ///
    /// # Errors
    ///
    /// Will return a [`ParseError`], when either one of the following cases occurs (in order of appearance):
    ///     1. If there is no node in the document, that has a class called [`ROOT_NODE_CLASS_SELECTOR`]. This indicates that a wrong html file was passed.
    ///     2. If the number of dates does not match the number of days for which data exists. This case is more for completeness and should never occur

    pub fn transform(html: &str) -> Result<Vec<(Date, ParseCanteen)>, ParseError> {
        let document = Html::parse_document(html);
        let root_node = Self::get_root_node(&document)?;
        let dates = Self::get_dates(&root_node);
        let canteens = Self::get_canteens(&root_node);
        if dates.len() != canteens.len() {
            return Err(ParseError::InvalidHtmlDocument);
        }
        // Here we have two vectors of the same length: One containing Date and one containing ParseCanteen. In order to get one containing tuples of both we use zip()
        Ok(dates.into_iter().zip(canteens.into_iter()).collect())
    }

    fn get_canteens(root_node: &ElementRef) -> Vec<ParseCanteen> {
        let mut canteens = Vec::new();
        for day_node in Self::get_day_nodes(root_node) {
            canteens.extend(Self::get_canteen(root_node, &day_node).into_iter());
        }
        canteens
    }

    fn get_canteen(root_node: &ElementRef, day_node: &ElementRef) -> Option<ParseCanteen> {
        Self::get_canteen_name(root_node).map(|name| ParseCanteen {
            name,
            lines: Self::get_lines(day_node),
        })
    }

    fn get_lines(day_node: &ElementRef) -> Vec<ParseLine> {
        let mut lines: Vec<ParseLine> = Vec::new();
        for line_node in Self::get_line_nodes(day_node) {
            lines.extend(Self::get_line(&line_node).into_iter());
        }
        lines
    }

    fn get_line(line_node: &ElementRef) -> Option<ParseLine> {
        Self::get_line_name(line_node).map(|name| ParseLine {
            name,
            dishes: Self::get_dishes(line_node),
        })
    }

    fn get_dishes(line_node: &ElementRef) -> Vec<Dish> {
        let mut dishes: Vec<Dish> = Vec::new();
        for dish_node in Self::get_dish_nodes(line_node) {
            dishes.extend(Self::get_dish(&dish_node).into_iter());
        }
        dishes
    }

    fn get_dish(dish_node: &ElementRef) -> Option<Dish> {
        Self::get_dish_name(dish_node).map(|name| Dish {
            name,
            price: Self::get_dish_price(dish_node),
            allergens: Self::get_dish_allergens(dish_node),
            additives: Self::get_dish_additives(dish_node),
            meal_type: Self::get_dish_type(dish_node),
            env_score: Self::get_dish_env_score(dish_node),
        })
    }

    fn get_root_node(document: &Html) -> Result<ElementRef, ParseError> {
        let selector = Selector::parse(ROOT_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        document
            .select(&selector)
            .next()
            .ok_or(ParseError::InvalidHtmlDocument)
    }

    fn get_day_nodes<'a>(root_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(DAY_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        root_node.select(&selector).collect()
    }

    fn get_line_nodes<'a>(day_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(LINE_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        day_node.select(&selector).collect()
    }

    fn get_dish_nodes<'a>(line_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let mut dish_nodes = Vec::new();
        for i in 0..NUMBER_OF_MEAL_TYPES {
            let selector = Selector::parse(&format!("{DISH_NODE_CLASS_SELECTOR}{i}"))
                .expect(SELECTOR_PARSE_E_MSG);
            dish_nodes.append(&mut line_node.select(&selector).collect());
        }
        dish_nodes
    }

    fn get_dates(root_node: &ElementRef) -> Vec<Date> {
        Self::get_date_super_node(root_node)
            .map(|date_super_node| {
                let date_nodes = Self::get_date_nodes(&date_super_node);
                let test: Vec<Date> = date_nodes
                    .into_iter()
                    .filter_map(|date_node| date_node.value().attr(DAY_DATE_ATTRIBUTE_NAME))
                    .filter_map(|date_string| Date::parse_from_str(date_string, DATE_FORMAT).ok())
                    .collect();
                test
            })
            .unwrap_or_default()
    }

    fn get_date_super_node<'a>(root_node: &'a ElementRef<'a>) -> Option<ElementRef<'a>> {
        let selector =
            Selector::parse(DAY_DATE_SUPER_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        root_node.select(&selector).next()
    }

    fn get_date_nodes<'a>(date_super_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(DAY_DATE_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        date_super_node.select(&selector).collect()
    }

    fn get_canteen_name(root_node: &ElementRef) -> Option<String> {
        let selector =
            Selector::parse(CANTEEN_NAME_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        root_node
            .select(&selector)
            .next()
            .map(|canteen_node| canteen_node.inner_html())
    }

    fn get_line_name(line_node: &ElementRef) -> Option<String> {
        let selector = Selector::parse(LINE_NAME_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        let line_name_node = line_node.select(&selector).next()?;
        Some(
            line_name_node
                .text()
                .collect::<Vec<_>>()
                .join(" ")
                .trim()
                .to_owned(),
        )
    }

    fn get_dish_name(dish_node: &ElementRef) -> Option<String> {
        let selector = Selector::parse(DISH_NAME_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        let dish_name_node = dish_node.select(&selector).next()?;
        Some(Self::remove_multiple_whitespaces(
            &dish_name_node.text().collect::<String>(),
        ))
    }

    fn remove_multiple_whitespaces(string: &str) -> String {
        string
            .split_whitespace()
            .collect::<Vec<_>>()
            .join(" ")
            .trim()
            .to_owned()
    }

    fn get_dish_price(dish_node: &ElementRef) -> Price {
        let mut prices = [0_u32; 4];
        for i in 1..5 {
            let selector = Selector::parse(&format!("{DISH_PRICE_NODE_CLASS_SELECTOR}{i}"))
                .expect(SELECTOR_PARSE_E_MSG);
            if let Some(price_node) = dish_node.select(&selector).next() {
                prices[i - 1] =
                    Self::get_price_through_regex(&price_node.inner_html()).unwrap_or_default();
            }
        }
        Price {
            price_student: prices[0],
            price_guest: prices[1],
            price_employee: prices[2],
            price_pupil: prices[3],
        }
    }

    fn get_price_through_regex(string: &str) -> Option<u32> {
        let regex = Regex::new(PRICE_REGEX).expect(REGEX_PARSE_E_MSG);
        let capture = regex.captures(string)?;
        let euros = capture.get(1)?.as_str();
        let cents = capture.get(2)?.as_str();
        format!("{euros}{cents}").parse().ok()
    }

    fn get_dish_allergens(dish_node: &ElementRef) -> Vec<Allergen> {
        let selector = Selector::parse(DISH_INFO_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        dish_node
            .select(&selector)
            .next()
            .map(|allergens_node| {
                let allergens_raw = allergens_node.inner_html();
                let regex = Regex::new(ALLERGEN_REGEX).expect(REGEX_PARSE_E_MSG);
                regex
                    .find_iter(&allergens_raw)
                    .filter_map(|a| Allergen::parse(a.as_str()))
                    .collect()
            })
            .unwrap_or_default()
    }

    fn get_dish_additives(dish_node: &ElementRef) -> Vec<Additive> {
        let selector = Selector::parse(DISH_INFO_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        dish_node
            .select(&selector)
            .next()
            .map(|additives_node| {
                let additives_raw = additives_node.inner_html();
                let regex = Regex::new(ADDITIVE_REGEX).expect(REGEX_PARSE_E_MSG);
                regex
                    .find_iter(&additives_raw)
                    .filter_map(|a| Additive::parse(a.as_str()))
                    .collect()
            })
            .unwrap_or_default()
    }

    fn get_dish_type(dish_node: &ElementRef) -> MealType {
        let selector = Selector::parse(DISH_TYPE_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        dish_node
            .select(&selector)
            .next()
            .map_or(MealType::Unknown, |dish_type_node| {
                let title = dish_type_node
                    .value()
                    .attr(DISH_TYPE_ATTRIBUTE_NAME)
                    .unwrap_or_default();
                MealType::parse(title)
            })
    }

    fn get_dish_env_score(dish_node: &ElementRef) -> u32 {
        let selector = Selector::parse(ENV_SCORE_NODE_CLASS_SELECTOR).expect(SELECTOR_PARSE_E_MSG);
        let env_score_node = dish_node.select(&selector).next();
        env_score_node
            .and_then(|x| x.value().attr(ENV_SCORE_ATTRIBUTE_NAME))
            .and_then(|s| s.parse::<u32>().ok())
            .unwrap_or_default()
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use std::{
        fs::{self, File},
        io::Write,
    };

    use crate::{
        interface::mensa_parser::model::ParseCanteen,
        layer::data::swka_parser::html_parser::HTMLParser, util::Date,
    };

    #[tokio::test]
    async fn test_1() {
        test_html(
            "./test_data/test_1.html",
            include_str!("./test_data/test_1.html"),
        );
    }

    #[tokio::test]
    async fn test_normal() {
        test_html(
            "./test_data/test_normal.html",
            include_str!("./test_data/test_normal.html"),
        );
    }

    #[tokio::test]
    async fn test_no_meal_data() {
        test_html(
            "./test_data/test_no_meal_data.html",
            include_str!("./test_data/test_no_meal_data.html"),
        );
    }

    #[tokio::test]
    async fn test_no_mealplan_shown() {
        test_html(
            "./test_data/test_no_mealplan_shown.html",
            include_str!("./test_data/test_no_mealplan_shown.html"),
        );
    }

    #[tokio::test]
    async fn test_mensa_moltke() {
        test_html(
            "./test_data/test_mensa_moltke.html",
            include_str!("./test_data/test_mensa_moltke.html"),
        );
    }

    fn test_html(path: &str, file_contents: &str) {
        let canteen_data = HTMLParser::transform(file_contents).unwrap();
        //write_output_to_file(path, &canteen_data);
        let contents = read_from_file(path);
        assert!(contents.is_ok());
        let contents = contents.unwrap().replace("\r\n", "\n");
        assert_eq!(format!("{canteen_data:#?}"), contents);
    }
    #[allow(dead_code)]
    fn write_output_to_file(
        path: &str,
        canteen_data: &[(Date, ParseCanteen)],
    ) -> std::io::Result<()> {
        let output_path = path
            .replace(".html", ".txt")
            .replace("./", "src/layer/data/swka_parser/");
        let mut output = File::create(output_path)?;
        write!(output, "{canteen_data:#?}")
    }

    fn read_from_file(path: &str) -> std::io::Result<String> {
        let input_path = path
            .replace(".html", ".txt")
            .replace("./", "src/layer/data/swka_parser/");
        fs::read_to_string(input_path)
    }
}
