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
//!     <!-- This is the super node of the date node identified by -->
//!     <!--`DATE_SUPER_NODE_CLASS_SELECTOR` it contains several date nodes. See below: -->
//!     <ul class="canteen-day-nav">
//!     <!-- This is a date node identified by `DATE_NODE_CLASS_SELECTOR` -->
//!     <!-- it contains an attribute identified by `DATE_ATTRIBUTE_NAME`, -->
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
    model::{Dish, ParseCanteen, ParseEnvironmentInfo, ParseLine},
    ParseError,
};
use crate::util::{Additive, Allergen, Date, FoodType, NutritionData, Price};
use lazy_static::lazy_static;
use regex::Regex;
use scraper::element_ref::Text;
use scraper::{ElementRef, Html, Selector};

lazy_static! {
    static ref ROOT_NODE_CLASS_SELECTOR: Selector = Selector::parse("div.main-content").expect(SELECTOR_PARSE_E_MSG);
    static ref CANTEEN_NAME_NODE_CLASS_SELECTOR: Selector = Selector::parse("h1.mensa_fullname").expect(SELECTOR_PARSE_E_MSG);

    static ref DATE_SUPER_NODE_CLASS_SELECTOR: Selector = Selector::parse("ul.canteen-day-nav").expect(SELECTOR_PARSE_E_MSG);
    static ref DATE_NODE_CLASS_SELECTOR: Selector = Selector::parse("a").expect(SELECTOR_PARSE_E_MSG);
    static ref DAY_NODE_CLASS_SELECTOR: Selector = Selector::parse("div.canteen-day").expect(SELECTOR_PARSE_E_MSG);

    static ref LINE_NODE_CLASS_SELECTOR: Selector = Selector::parse("tr.mensatype_rows").expect(SELECTOR_PARSE_E_MSG);
    static ref LINE_NAME_NODE_CLASS_SELECTOR: Selector = Selector::parse("td.mensatype").expect(SELECTOR_PARSE_E_MSG);

    static ref DISH_TYPE_NODE_CLASS_SELECTOR: Selector = Selector::parse("img.mealicon_2").expect(SELECTOR_PARSE_E_MSG);
    static ref DISH_NAME_NODE_CLASS_SELECTOR: Selector = Selector::parse("span.bg").expect(SELECTOR_PARSE_E_MSG);
    static ref DISH_INFO_NODE_CLASS_SELECTOR: Selector = Selector::parse("sup").expect(SELECTOR_PARSE_E_MSG);
    static ref ENV_SCORE_NODE_CLASS_SELECTOR: Selector = Selector::parse("div.enviroment_score.average").expect(SELECTOR_PARSE_E_MSG);

    static ref CO2_RATING_SELECTOR: Selector = Selector::parse("div.co2_bewertung").expect(SELECTOR_PARSE_E_MSG);
    static ref CO2_ALTERNATIVE_RATING_SELECTOR: Selector = Selector::parse("div.co2_bewertung_wolke").expect(SELECTOR_PARSE_E_MSG);
    static ref WATER_RATING_SELECTOR: Selector = Selector::parse("div.wasser_bewertung").expect(SELECTOR_PARSE_E_MSG);
    static ref ANIMAL_WELFARE_RATING_SELECTOR: Selector = Selector::parse("div.tierwohl").expect(SELECTOR_PARSE_E_MSG);
    static ref RAINFOREST_RATING_SELECTOR: Selector = Selector::parse("div.regenwald").expect(SELECTOR_PARSE_E_MSG);
    static ref VALUE_SELECTOR: Selector = Selector::parse("div.value").expect(SELECTOR_PARSE_E_MSG);
    static ref RATING_SELECTOR: Selector = Selector::parse("div.enviroment_score.co2-label").expect(SELECTOR_PARSE_E_MSG);

    /// A Regex for getting prices in euros. A price consists of 1 or more digits, followed by a comma and then exactly two digits.
    static ref PRICE_REGEX: Regex = Regex::new(r"([0-9]*),([0-9]{2})").expect(REGEX_PARSE_E_MSG);
    /// A Regex for getting allergens. An allergen consists of a single Uppercase letter followed by one or more upper- or lowercase letters (indicated by \w+).
    static ref ALLERGEN_REGEX: Regex = Regex::new(r"[A-Z]\w+").expect(REGEX_PARSE_E_MSG);
    /// A regex for getting additives. An additive consists of one or two digits.
    static ref ADDITIVE_REGEX: Regex = Regex::new(r"[0-9]{1,2}").expect(REGEX_PARSE_E_MSG);

    static ref ENERGY_REGEX: Regex = Regex::new(r"([0-9]+) kcal").expect(REGEX_PARSE_E_MSG);

    static ref WEIGHT_REGEX: Regex = Regex::new(r"([0-9]+) g").expect(REGEX_PARSE_E_MSG);

    static ref VOLUME_REGEX: Regex = Regex::new(r"([0-9]*),([0-9]{2}) l").expect(REGEX_PARSE_E_MSG);

    static ref ID_REGEX: Regex = Regex::new(r"[0-9]{18,}").expect(REGEX_PARSE_E_MSG);

    static ref POULTRY_REGEX: Regex = Regex::new(r"(Pute|(G|g)eflügel|H(ü|ä|u|a)hn)").expect(REGEX_PARSE_E_MSG);
}

const DISH_NODE_CLASS_SELECTOR_PREFIX: &str = "tr.mt-";
const DISH_PRICE_NODE_CLASS_SELECTOR_PREFIX: &str = "span.bgp.price_";

const DATE_ATTRIBUTE_NAME: &str = "rel";
const DISH_TYPE_ATTRIBUTE_NAME: &str = "title";

const DATE_FORMAT: &str = "%Y-%m-%d";

const NUMBER_OF_FOOD_TYPES: usize = 8;
const PRICE_TYPE_COUNT: usize = 4;
const NUMBER_OF_MILLILITRES_PER_LITRE: u32 = 1000;

const LINE_CLOSED_MEAL_NAME: &str = "GESCHLOSSEN";

const RATING_NAME: &str = "data-rating";
const MAX_RATING_NAME: &str = "data-numstars";

const ENERGY_NAME: &str = "energie";
const PROTEIN_NAME: &str = "proteine";
const CARBOHYDRATE_NAME: &str = "kohlenhydrate";
const SUGAR_NAME: &str = "zucker";
const FAT_NAME: &str = "fett";
const SATURATED_FAT_NAME: &str = "gesaettigt";
const SALT_NAME: &str = "salz";

const SELECTOR_PARSE_E_MSG: &str = "Error while parsing Selector string";
const REGEX_PARSE_E_MSG: &str = "Error while parsing regex string";
const INVALID_ROOT_NODE_MESSAGE: &str =
    "could not find mensa root node. this could mean a wrong webpage got loaded";

/// A static class, that transforms html files into datatypes, that can be used for further processing using the `HTMLParser::transform` function.
#[derive(Debug)]
pub struct HTMLParser;

impl HTMLParser {
    /// Method for creating a [`HTMLParser`] instance.
    #[must_use]
    pub const fn new() -> Self {
        Self
    }

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
    /// let canteen_data = HTMLParser::new().transform(include_str!("./test_data/test_normal.html"), 42_u32).unwrap();
    /// ```
    ///
    /// # Errors
    ///
    /// Will return a [`ParseError`], when either one of the following cases occurs (in order of appearance):
    ///     1. If there is no node in the document, that has a class called `div.main-content`, a wrong html file was passed.
    ///     2. If the number of dates does not match the number of days for which data exists. This case is more for completeness and should never occur
    pub fn transform(
        &self,
        html: &str,
        position: u32,
    ) -> Result<Vec<(Date, ParseCanteen)>, ParseError> {
        let document = Html::parse_document(html);
        let root_node = Self::get_root_node(&document)?;
        let dates = Self::get_dates(&root_node).unwrap_or_default();
        let canteen_for_all_days = Self::get_canteen_for_all_days(&root_node, position);
        if dates.len() != canteen_for_all_days.len() {
            return Err(ParseError::InvalidHtmlDocument(String::from(
                "provided non equal amount of dates for canteens",
            )));
        }
        // Here we have two vectors of the same length: One containing Date and one containing ParseCanteen. In order to get one containing tuples of both we use zip()
        Ok(dates.into_iter().zip(canteen_for_all_days).collect())
    }

    fn get_root_node(document: &Html) -> Result<ElementRef, ParseError> {
        document
            .select(&ROOT_NODE_CLASS_SELECTOR)
            .next()
            .ok_or_else(|| {
                ParseError::InvalidHtmlDocument(format!(
                    "{INVALID_ROOT_NODE_MESSAGE}: {:?}",
                    *ROOT_NODE_CLASS_SELECTOR
                ))
            })
    }

    fn get_dates(root_node: &ElementRef) -> Option<Vec<Date>> {
        let date_super_node = Self::get_date_super_node(root_node)?;
        let date_nodes = Self::get_date_nodes(&date_super_node);
        Some(
            date_nodes
                .into_iter()
                .filter_map(|date_node| date_node.value().attr(DATE_ATTRIBUTE_NAME))
                .filter_map(|date_string| Date::parse_from_str(date_string, DATE_FORMAT).ok())
                .collect(),
        )
    }

    fn get_date_super_node<'a>(root_node: &'a ElementRef<'a>) -> Option<ElementRef<'a>> {
        root_node.select(&DATE_SUPER_NODE_CLASS_SELECTOR).next()
    }

    fn get_date_nodes<'a>(date_super_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        date_super_node.select(&DATE_NODE_CLASS_SELECTOR).collect()
    }

    fn get_canteen_for_all_days(root_node: &ElementRef, position: u32) -> Vec<ParseCanteen> {
        Self::get_day_nodes(root_node)
            .into_iter()
            .filter_map(|day_node| Self::get_canteen_for_single_day(root_node, &day_node, position))
            .collect()
    }

    fn get_day_nodes<'a>(root_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        root_node.select(&DAY_NODE_CLASS_SELECTOR).collect()
    }

    fn get_canteen_for_single_day(
        root_node: &ElementRef,
        day_node: &ElementRef,
        position: u32,
    ) -> Option<ParseCanteen> {
        Some(ParseCanteen {
            name: Self::get_canteen_name(root_node)?,
            lines: Self::get_lines(day_node),
            pos: position,
        })
    }

    fn get_canteen_name(root_node: &ElementRef) -> Option<String> {
        let canteen_node = root_node.select(&CANTEEN_NAME_NODE_CLASS_SELECTOR).next()?;
        Some(canteen_node.inner_html())
    }

    fn get_lines(day_node: &ElementRef) -> Vec<ParseLine> {
        Self::get_line_nodes(day_node)
            .into_iter()
            .enumerate()
            .filter_map(|(pos, line_node)| Self::get_line(&line_node, pos))
            .collect()
    }

    fn get_line_nodes<'a>(day_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        day_node.select(&LINE_NODE_CLASS_SELECTOR).collect()
    }

    fn get_line(line_node: &ElementRef, pos: usize) -> Option<ParseLine> {
        Some(ParseLine {
            name: Self::get_line_name(line_node)?,
            dishes: Self::get_dishes(line_node),
            pos: u32::try_from(pos).expect("u32 could not be casted from usize"),
        })
    }

    fn get_line_name(line_node: &ElementRef) -> Option<String> {
        let line_name_node = line_node.select(&LINE_NAME_NODE_CLASS_SELECTOR).next()?;
        Some(Self::remove_unnecessary_html(line_name_node.text()))
    }

    fn remove_unnecessary_html(text: Text<'_>) -> String {
        text.collect::<Vec<_>>().join(" ").trim().to_owned()
    }

    fn get_dishes(line_node: &ElementRef) -> Vec<Dish> {
        Self::get_dish_nodes(line_node)
            .into_iter()
            .filter_map(|dish_node| Self::get_dish(&dish_node))
            .collect()
    }

    fn get_dish_nodes<'a>(line_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        (0..NUMBER_OF_FOOD_TYPES)
            .filter_map(|i| Selector::parse(&format!("{DISH_NODE_CLASS_SELECTOR_PREFIX}{i}")).ok())
            .flat_map(|selector| line_node.select(&selector).collect::<Vec<_>>())
            .collect()
    }

    fn get_dish(dish_node: &ElementRef) -> Option<Dish> {
        let name = Self::get_dish_name(dish_node)?;
        Some(Dish {
            name: name.clone(),
            price: Self::get_dish_price(dish_node),
            allergens: Self::get_dish_allergens(dish_node).unwrap_or_default(),
            additives: Self::get_dish_additives(dish_node).unwrap_or_default(),
            food_type: Self::get_dish_type(dish_node, &name).unwrap_or(FoodType::Unknown),
            env_score: Self::get_dish_env_score(dish_node),
            nutrition_data: Self::get_dish_nutrition_data(dish_node),
        })
    }

    fn get_dish_name(dish_node: &ElementRef) -> Option<String> {
        let dish_name_node = dish_node.select(&DISH_NAME_NODE_CLASS_SELECTOR).next()?;
        let dish_name =
            Self::remove_multiple_whitespaces(&dish_name_node.text().collect::<String>());
        if dish_name == LINE_CLOSED_MEAL_NAME {
            None
        } else {
            Some(dish_name)
        }
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
        let mut prices = (1..=PRICE_TYPE_COUNT)
            .filter_map(|i| {
                Selector::parse(&format!("{DISH_PRICE_NODE_CLASS_SELECTOR_PREFIX}{i}")).ok()
            })
            .filter_map(|selector| dish_node.select(&selector).next())
            .filter_map(|price_node| Self::get_price_through_regex(&price_node.inner_html()));
        Price {
            price_student: prices.next().unwrap_or_default(),
            price_guest: prices.next().unwrap_or_default(),
            price_employee: prices.next().unwrap_or_default(),
            price_pupil: prices.next().unwrap_or_default(),
        }
    }

    fn get_price_through_regex(string: &str) -> Option<u32> {
        let capture = PRICE_REGEX.captures(string)?;
        let euros = capture.get(1)?.as_str();
        let cents = capture.get(2)?.as_str();
        format!("{euros}{cents}").parse().ok()
    }

    fn get_dish_allergens(dish_node: &ElementRef) -> Option<Vec<Allergen>> {
        let allergens_node = dish_node.select(&DISH_INFO_NODE_CLASS_SELECTOR).next()?;
        Some(Self::get_allergens_through_regex(
            &allergens_node.inner_html(),
        ))
    }

    fn get_allergens_through_regex(string: &str) -> Vec<Allergen> {
        ALLERGEN_REGEX
            .find_iter(string)
            .filter_map(|a| Allergen::parse(a.as_str()))
            .collect()
    }

    fn get_dish_additives(dish_node: &ElementRef) -> Option<Vec<Additive>> {
        let additives_node = dish_node.select(&DISH_INFO_NODE_CLASS_SELECTOR).next()?;
        Some(Self::get_additives_through_regex(
            &additives_node.inner_html(),
        ))
    }

    fn get_additives_through_regex(string: &str) -> Vec<Additive> {
        ADDITIVE_REGEX
            .find_iter(string)
            .filter_map(|a| Additive::parse(a.as_str()))
            .collect()
    }

    fn get_dish_type(dish_node: &ElementRef, name: &str) -> Option<FoodType> {
        let dish_type_node = dish_node.select(&DISH_TYPE_NODE_CLASS_SELECTOR).next();
        if let Some(dish_type_node) = dish_type_node {
            let preliminary_dish_type = dish_type_node
                .value()
                .attr(DISH_TYPE_ATTRIBUTE_NAME)
                .map(FoodType::parse);
            if preliminary_dish_type.is_none() || Some(FoodType::Unknown) == preliminary_dish_type {
                return Self::check_for_poultry(name);
            }
            preliminary_dish_type
        } else {
            Self::check_for_poultry(name)
        }
    }

    fn check_for_poultry(name: &str) -> Option<FoodType> {
        if POULTRY_REGEX.captures(name).is_some() {
            Some(FoodType::Poultry)
        } else {
            None
        }
    }

    fn get_dish_env_score(dish_node: &ElementRef) -> Option<ParseEnvironmentInfo> {
        let env_info = ParseEnvironmentInfo {
            co2_rating: Self::get_co2_rating(dish_node)?,
            co2_value: Self::get_co2_value(dish_node)?,
            water_rating: Self::get_rating(dish_node, &WATER_RATING_SELECTOR)?,
            water_value: Self::get_water_value(dish_node)?,
            animal_welfare_rating: Self::get_rating(dish_node, &ANIMAL_WELFARE_RATING_SELECTOR)?,
            rainforest_rating: Self::get_rating(dish_node, &RAINFOREST_RATING_SELECTOR)?,
            max_rating: Self::get_max_rating(dish_node, &RAINFOREST_RATING_SELECTOR)?,
        };
        Some(env_info)
    }

    fn get_co2_rating(dish_node: &ElementRef) -> Option<u32> {
        Self::get_rating(dish_node, &CO2_RATING_SELECTOR)
            .or_else(|| Self::get_rating(dish_node, &CO2_ALTERNATIVE_RATING_SELECTOR))
    }

    fn get_co2_value(dish_node: &ElementRef) -> Option<u32> {
        let raw_value = Self::get_value(dish_node, &CO2_RATING_SELECTOR)
            .or_else(|| Self::get_value(dish_node, &CO2_ALTERNATIVE_RATING_SELECTOR))?;
        WEIGHT_REGEX
            .captures(&raw_value)?
            .get(1)?
            .as_str()
            .parse()
            .ok()
    }

    fn get_water_value(dish_node: &ElementRef) -> Option<u32> {
        let raw_value = Self::get_value(dish_node, &WATER_RATING_SELECTOR)?;
        Self::get_water_value_through_regex(&raw_value)
    }

    fn get_water_value_through_regex(string: &str) -> Option<u32> {
        let capture = VOLUME_REGEX.captures(string)?;
        let litres = capture.get(1)?.as_str().parse::<u32>().ok()?;
        let millilitres = capture.get(2)?.as_str().parse::<u32>().ok()? * 10;
        Some(litres * NUMBER_OF_MILLILITRES_PER_LITRE + millilitres)
    }

    fn get_rating(dish_node: &ElementRef, information_area_selector: &Selector) -> Option<u32> {
        Self::get_ratings(dish_node, information_area_selector, RATING_NAME)
    }
    fn get_max_rating(dish_node: &ElementRef, information_area_selector: &Selector) -> Option<u32> {
        Self::get_ratings(dish_node, information_area_selector, MAX_RATING_NAME)
    }

    fn get_ratings(
        dish_node: &ElementRef,
        information_area_selector: &Selector,
        attribute_name: &str,
    ) -> Option<u32> {
        let value_node =
            Self::get_env_score_value_node(dish_node, information_area_selector, &RATING_SELECTOR)?;
        value_node.value().attr(attribute_name)?.parse().ok()
    }

    fn get_value(dish_node: &ElementRef, information_area_selector: &Selector) -> Option<String> {
        let value_node =
            Self::get_env_score_value_node(dish_node, information_area_selector, &VALUE_SELECTOR)?;
        Some(Self::remove_multiple_whitespaces(
            &value_node.text().collect::<String>(),
        ))
    }

    fn get_env_score_value_node<'a>(
        dish_node: &'a ElementRef<'a>,
        information_area_selector: &Selector,
        field_selector: &Selector,
    ) -> Option<ElementRef<'a>> {
        let env_score_node = Self::get_nutrition_node(dish_node)?;
        let value_node = env_score_node.select(information_area_selector).next()?;
        value_node.select(field_selector).next()
    }

    fn get_dish_nutrition_data(dish_node: &ElementRef) -> Option<NutritionData> {
        let nutrition_node = Self::get_nutrition_node(dish_node)?;
        Some(NutritionData {
            energy: Self::get_nutrients(&nutrition_node, ENERGY_NAME, &ENERGY_REGEX)?,
            protein: Self::get_nutrients(&nutrition_node, PROTEIN_NAME, &WEIGHT_REGEX)?,
            carbohydrates: Self::get_nutrients(&nutrition_node, CARBOHYDRATE_NAME, &WEIGHT_REGEX)?,
            sugar: Self::get_nutrients(&nutrition_node, SUGAR_NAME, &WEIGHT_REGEX)?,
            fat: Self::get_nutrients(&nutrition_node, FAT_NAME, &WEIGHT_REGEX)?,
            saturated_fat: Self::get_nutrients(&nutrition_node, SATURATED_FAT_NAME, &WEIGHT_REGEX)?,
            salt: Self::get_nutrients(&nutrition_node, SALT_NAME, &WEIGHT_REGEX)?,
        })
    }

    fn get_nutrition_node<'a>(dish_node: &'a ElementRef<'a>) -> Option<ElementRef<'a>> {
        let meal_id = Self::get_meal_id(dish_node)?;
        let string = format!("td.nutrition_facts_row.co2_id-{meal_id}");
        let selector = Selector::parse(&string).ok()?;
        let node = ElementRef::wrap(dish_node.parent()?)?;
        node.select(&selector).next()
    }

    fn get_meal_id(dish_node: &ElementRef) -> Option<String> {
        Some(ID_REGEX.find(&dish_node.html())?.as_str().to_string())
    }

    fn get_nutrients(nutrition_node: &ElementRef, name: &str, regex: &Regex) -> Option<u32> {
        let selector = Selector::parse(&format!("div.{name}")).ok()?;
        let node = nutrition_node.select(&selector).next()?;
        regex
            .captures(&node.inner_html())?
            .get(1)?
            .as_str()
            .parse()
            .ok()
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
        test_html("src/layer/data/swka_parser/test_data/test_1.html");
    }

    #[tokio::test]
    async fn test_normal() {
        test_html("src/layer/data/swka_parser/test_data/test_normal.html");
    }

    #[tokio::test]
    async fn test_no_meal_data() {
        test_html("src/layer/data/swka_parser/test_data/test_no_meal_data.html");
    }

    #[tokio::test]
    async fn test_no_mealplan_shown() {
        test_html("src/layer/data/swka_parser/test_data/test_no_mealplan_shown.html");
    }

    #[tokio::test]
    async fn test_mensa_moltke() {
        test_html("src/layer/data/swka_parser/test_data/test_mensa_moltke.html");
    }

    #[tokio::test]
    async fn test_not_a_canteen() {
        test_html("src/layer/data/swka_parser/test_data/test_not_a_canteen.html");
    }

    #[tokio::test]
    async fn test_not_a_canteen_de() {
        test_html("src/layer/data/swka_parser/test_data/test_not_a_canteen_de.html");
    }

    #[tokio::test]
    async fn test_canteen_closed_de() {
        test_html("src/layer/data/swka_parser/test_data/test_canteen_closed_de.html");
    }

    #[tokio::test]
    async fn test_canteen_closed() {
        test_html("src/layer/data/swka_parser/test_data/test_canteen_closed.html");
    }

    #[tokio::test]
    /// Tests an html page, that is not from the Studierendenwerk Karlsruhe. (Source: https://cbracco.github.io/html5-test-page/)
    async fn test_invalid() {
        let path = "src/layer/data/swka_parser/test_data/test_invalid.html";
        let file_contents = read_from_file(path).unwrap();
        let canteen_data = HTMLParser::new().transform(&file_contents, 42_u32);
        assert!(canteen_data.is_err());
    }

    fn test_html(path: &str) {
        let file_contents = read_from_file(path).unwrap();
        let canteen_data = HTMLParser::new().transform(&file_contents, 42_u32).unwrap();

        //let _ = write_output_to_file(path, &canteen_data);
        let expected = read_from_file(&path.replace(".html", ".txt"))
            .unwrap()
            .replace("\r\n", "\n");
        assert_eq!(format!("{canteen_data:#?}"), expected);
    }
    #[allow(dead_code)]
    fn write_output_to_file(
        path: &str,
        canteen_data: &[(Date, ParseCanteen)],
    ) -> std::io::Result<()> {
        let output_path = path.replace(".html", ".txt");
        let mut output = File::create(output_path)?;
        write!(output, "{canteen_data:#?}")
    }

    fn read_from_file(path: &str) -> std::io::Result<String> {
        fs::read_to_string(path)
    }
}
