//! The general structure of the html file is as follows: (// Are added comments)
//! ```html
//! //...
//! // This is the root node identified by `ROOT_NODE_CLASS`
//! <div class="main-content iwsetter">      
//!
//! //...
//!     // This is the canteen name node identified by `CANTEEN_NAME_NODE_CLASS`
//!     // it contains the name of the canteen
//!     <h1 class="mensa_fullname">Dining Hall am Adenauerring</h1>
//! //...
//!     // This is the super node of the day date node identified by
//!     // `DAY_DATE_SUPER_NODE_CLASS` it contains several day nodes. See below:
//!     <ul class="canteen-day-nav">
//!     // This is a day date node identified by `DAY_DATE_NODE_CLASS`
//!     // it contains an attribute identified by `DAY_DATE_ATTRIBUTE_NAME`,
//!     // which contains the date
//!     <li>
//!         <a id="canteen_day_nav_1"
//!             rel="2023-07-10"
//!             href="javascript:;"onClick="setCanteenDate('2023-07-10');setCanteenDiv(1);">
//!             <span>Mo 10.07.</span>
//!         </a>
//!     </ul>
//! //...
//!     // This is a day node identified by `DAY_NODE_CLASS`
//!     // it contains all of the lines (which contain dishes) for the day
//!     <div id="canteen_day_1" class="canteen-day">
//! //...
//!         // This is a line node identified by `LINE_NODE_CLASS`
//!         // it contains all of the line information (name and dishes)
//!         <tr class="mensatype_rows">
//!             // This is a line name node identified by `LINE_NAME_NODE_CLASS`
//!             // it contains the name of the line                
//!             <td class="mensatype" style="white-space: normal !important;">
//!                 <div>Linie 1<br>Gut & Günstig</div>
//!             </td>
//! //...
//!             // This is a dish node identified by `DISH_NODE_CLASS+number between 0 and 8`
//!             // it contains the dish information
//!             <tr class="mt-7">
//!                 <td class="mtd-icon">
//!                     // This is a dish type node identified by `DISH_TYPE_NODE_CLASS`
//!                     // it contains an attribute called `DISH_TYPE_ATTRIBUTE_NAME`,
//!                     // which contains the meal type
//!                     <div>
//!                         <img src="/layout/icons/vegetarisches-gericht.svg"
//!                         class="mealicon_2"
//!                         title="vegetarisches Gericht"><br>
//!                     </div>
//!                 </td>
//!                 <td class="first menu-title" id="menu-title-5240287810491942285">
//!                     // This is the dish name node identified by `DISH_NAME_NODE_CLASS`
//!                     // it contains the name of the dish
//!                     <span onclick="toggleRating('5240287810491942285');" class="bg">
//!                         <b>2 Dampfnudeln mit Vanillesoße</b>
//!                     </span>
//!                     // This is the dish info node identified by `DISH_INFO_NODE_CLASS`
//!                     // it contains the allergens and additives of the dish
//!                     <sup>[Ei,ML,We]</sup>
//!                 </td>
//!                 <td style="text-align: right;vertical-align:bottom;">
//!                     // These are dish price nodes identified by `DISH_PRICE_NODE_CLASS`
//!                     // they contain the prices of the meal.
//!                     // 1 = Student, 2 = Guest, 3 = Employee, 4 = Pupil
//!                     <span class="bgp price_1">3,20 &euro;</span>
//!                     <span class="bgp price_2">4,60 &euro;</span>
//!                     <span class="bgp price_3">4,20 &euro;</span>
//!                     <span class="bgp price_4">3,55 &euro;</span>
//!                     <div style="clear: both;"></div>
//!                     <a href="javascript:;"
//!                     title="&Oslash; Umwelt-Score"
//!                     onclick="toggleRating('5240287810491942285')">
//!                         // This is the environment score node identified by
//!                         // `ENV_SCORE_NODE_CLASS` it contains an attribute called
//!                         // `ENV_SCORE_ATTRIBUTE_NAME`, which contains the environment score
//!                         <div id="average-stars-1551112451474757280"
//!                             class="enviroment_score average" data-rating="3"
//!                             data-numstars="3"></div>
//!                     </a>
//!                 <tr>
//! //...
//! ```

use crate::interface::mensa_parser::{
    model::{Dish, ParseCanteen, ParseLine},
    ParseError,
};
use crate::util::{Additive, Allergen, Date, MealType, Price};
use regex::Regex;
use scraper::{ElementRef, Html, Selector};

/// For docs see [`self`]
const ROOT_NODE_CLASS: &str = "div.main-content";
/// For docs see [`self`]
const CANTEEN_NAME_NODE_CLASS: &str = "h1.mensa_fullname";

/// For docs see [`self`]
const DAY_DATE_SUPER_NODE_CLASS: &str = "ul.canteen-day-nav";
/// For docs see [`self`]
const DAY_DATE_NODE_CLASS: &str = "a";
/// For docs see [`self`]
const DAY_DATE_ATTRIBUTE_NAME: &str = "rel";
/// For docs see [`self`]
const DAY_NODE_CLASS: &str = "div.canteen-day";

/// For docs see [`self`]
const LINE_NODE_CLASS: &str = "tr.mensatype_rows";
/// For docs see [`self`]
const LINE_NAME_NODE_CLASS: &str = "td.mensatype";

/// For docs see [`self`]
const DISH_NODE_CLASS: &str = "tr.mt-";
/// For docs see [`self`]
const DISH_TYPE_NODE_CLASS: &str = "img.mealicon_2";
/// For docs see [`self`]
const DISH_TYPE_ATTRIBUTE_NAME: &str = "title";
/// For docs see [`self`]
const DISH_NAME_NODE_CLASS: &str = "span.bg";
/// For docs see [`self`]
const DISH_INFO_NODE_CLASS: &str = "sup";
/// For docs see [`self`]
const DISH_PRICE_NODE_CLASS: &str = "span.bgp.price_";
/// For docs see [`self`]
const ENV_SCORE_NODE_CLASS: &str = "div.enviroment_score.average";
/// For docs see [`self`]
const ENV_SCORE_ATTRIBUTE_NAME: &str = "data-rating";

const DATE_FORMAT: &str = "%Y-%m-%d";
const PRICE_REGEX: &str = r"(?<euros>[0-9]),(?<cents>[0-9]{2})";
const ALLERGEN_REGEX: &str = r"[A-Z]\w+";
const ADDITIVE_REGEX: &str = r"[0-9]{1,2}";

const PARSE_E_MSG: &str = "Error while parsing";
const SELECTOR_PARSE_E_MSG: &str = "Error while parsing Selector string";
const REGEX_PARSE_E_MSG: &str = "Error while parsing regex string";

pub struct HTMLParser;

impl HTMLParser {
    /// Transforms an html document into a vector containing tuples of `Date` and `ParseCanteens`
    pub fn transform(html: &str) -> Result<Vec<(Date, ParseCanteen)>, ParseError> {
        let document = Html::parse_document(html);
        let root_node = Self::get_root_node(&document)?;
        let dates = Self::get_dates(&root_node);
        let canteens = Self::get_canteens(&root_node);
        if dates.len() == canteens.len() {
            // Here we have two vectors of the same length: One containing Date and one containing ParseCanteen. In order to get one containing tuples of both we use zip()
            Ok(dates.into_iter().zip(canteens.into_iter()).collect())
        } else {
            Err(ParseError::InvalidHtmlDocument)
        }
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
        let selector = Selector::parse(ROOT_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        document
            .select(&selector)
            .next()
            .ok_or(ParseError::InvalidHtmlDocument)
    }

    fn get_day_nodes<'a>(root_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(DAY_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        root_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_line_nodes<'a>(day_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(LINE_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        day_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_dish_nodes<'a>(line_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let mut dish_nodes = Vec::new();
        for i in 0..8 {
            let selector =
                Selector::parse(&format!("{DISH_NODE_CLASS}{i}")).expect(SELECTOR_PARSE_E_MSG);
            dish_nodes.append(&mut line_node.select(&selector).collect::<Vec<_>>());
        }
        dish_nodes
    }

    fn get_dates(root_node: &ElementRef) -> Vec<Date> {
        let selector = Selector::parse(DAY_DATE_SUPER_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        root_node
            .select(&selector)
            .next()
            .map_or_else(std::vec::Vec::new, |date_node| {
                let selector = Selector::parse(DAY_DATE_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
                let mut dates = Vec::new();
                for element in date_node.select(&selector) {
                    if let Some(date_string) = element.value().attr(DAY_DATE_ATTRIBUTE_NAME) {
                        dates.push(
                            Date::parse_from_str(date_string, DATE_FORMAT).expect(PARSE_E_MSG),
                        );
                    }
                }
                dates
            })
    }

    fn get_canteen_name(root_node: &ElementRef) -> Option<String> {
        let selector = Selector::parse(CANTEEN_NAME_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        root_node
            .select(&selector)
            .next()
            .map(|canteen_node| canteen_node.inner_html())
    }

    fn get_line_name(line_node: &ElementRef) -> Option<String> {
        let selector = Selector::parse(LINE_NAME_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        line_node.select(&selector).next().map(|line_name_node| {
            line_name_node
                .text()
                .collect::<Vec<_>>()
                .join(" ")
                .trim()
                .to_owned()
        })
    }

    fn get_dish_name(dish_node: &ElementRef) -> Option<String> {
        let selector = Selector::parse(DISH_NAME_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        dish_node.select(&selector).next().map(|dish_name_node| {
            Self::remove_multiple_whitespaces(&dish_name_node.text().collect::<String>())
        })
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
        let mut prices: [u32; 4] = [0; 4];
        for i in 1..5 {
            let selector = Selector::parse(&format!("{DISH_PRICE_NODE_CLASS}{i}"))
                .expect(SELECTOR_PARSE_E_MSG);
            if let Some(price_node) = dish_node.select(&selector).next() {
                let price_string: String = price_node.inner_html();
                let regex = Regex::new(PRICE_REGEX).expect(REGEX_PARSE_E_MSG);
                prices[i - 1] = regex.captures(&price_string).map_or(0, |capture| {
                    format!("{}{}", &capture["euros"], &capture["cents"])
                        .parse::<u32>()
                        .expect(PARSE_E_MSG)
                });
            }
        }
        Price {
            price_student: prices[0],
            price_guest: prices[1],
            price_employee: prices[2],
            price_pupil: prices[3],
        }
    }

    fn get_dish_allergens(dish_node: &ElementRef) -> Vec<Allergen> {
        let selector = Selector::parse(DISH_INFO_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        dish_node
            .select(&selector)
            .next()
            .map_or_else(std::vec::Vec::new, |allergens_node| {
                let allergens_raw = allergens_node.inner_html();
                let regex = Regex::new(ALLERGEN_REGEX).expect(REGEX_PARSE_E_MSG);
                regex
                    .find_iter(&allergens_raw)
                    .filter_map(|a| Allergen::parse(a.as_str()))
                    .collect()
            })
    }

    fn get_dish_additives(dish_node: &ElementRef) -> Vec<Additive> {
        let selector = Selector::parse(DISH_INFO_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        dish_node
            .select(&selector)
            .next()
            .map_or_else(std::vec::Vec::new, |additives_node| {
                let additives_raw = additives_node.inner_html();
                let regex = Regex::new(ADDITIVE_REGEX).expect(REGEX_PARSE_E_MSG);
                regex
                    .find_iter(&additives_raw)
                    .filter_map(|a| Additive::parse(a.as_str()))
                    .collect()
            })
    }

    fn get_dish_type(dish_node: &ElementRef) -> MealType {
        let selector = Selector::parse(DISH_TYPE_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let dish_type_nodes = dish_node.select(&selector).collect::<Vec<_>>();
        for dish_type_node in dish_type_nodes {
            let title = dish_type_node
                .value()
                .attr(DISH_TYPE_ATTRIBUTE_NAME)
                .unwrap_or_default();
            let dish_type = MealType::parse(title);
            if dish_type != MealType::Unknown {
                return dish_type;
            }
        }
        MealType::Unknown
    }

    fn get_dish_env_score(dish_node: &ElementRef) -> u32 {
        let selector = Selector::parse(ENV_SCORE_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let env_score_node = dish_node.select(&selector).next();
        env_score_node
            .and_then(|x| x.value().attr(ENV_SCORE_ATTRIBUTE_NAME))
            .and_then(|s| s.parse::<u32>().ok())
            .unwrap_or(0)
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
        test_html("./tests/test_1.html", include_str!("./tests/test_1.html"));
    }

    #[tokio::test]
    async fn test_normal() {
        test_html(
            "./tests/test_normal.html",
            include_str!("./tests/test_normal.html"),
        );
    }

    #[tokio::test]
    async fn test_no_meal_data() {
        test_html(
            "./tests/test_no_meal_data.html",
            include_str!("./tests/test_no_meal_data.html"),
        );
    }

    #[tokio::test]
    async fn test_no_mealplan_shown() {
        test_html(
            "./tests/test_no_mealplan_shown.html",
            include_str!("./tests/test_no_mealplan_shown.html"),
        );
    }

    #[tokio::test]
    async fn test_mensa_moltke() {
        test_html(
            "./tests/test_mensa_moltke.html",
            include_str!("./tests/test_mensa_moltke.html"),
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
