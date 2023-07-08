use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::util::{Additive, Allergen, Date, MealType, Price};
use regex::Regex;
use scraper::{ElementRef, Html, Selector};

const ROOT_CLASS: &str = "div.main-content";
const CANTEEN_NAME_CLASS: &str = "h1.mensa_fullname";

const DAY_CLASS: &str = "div.canteen-day";
const DAY_DATE_SUPER_CLASS: &str = "ul.canteen-day-nav";
const DAY_DATE_CLASS: &str = "a";
const DAY_DATE_ATTRIBUTE_NAME: &str = "rel";
const DATE_FORMAT: &str = "%Y-%m-%d";

const LINE_CLASS: &str = "tr.mensatype_rows";
const LINE_NAME_CLASS: &str = "td.mensatype";

const DISH_CLASS: &str = "tr.mt-";
const DISH_NAME_CLASS: &str = "span.bg";
const DISH_PRICE_CLASS: &str = "span.bgp.price_";
const DISH_INFO_CLASS: &str = "sup";
const ENV_SCORE_CLASS: &str = "div.enviroment_score.average";
const ENV_SCORE_ATTRIBUTE_NAME: &str = "data-rating";
const DISH_TYPE_NODE_CLASS: &str = "img.mealicon_2";
const DISH_TYPE_ATTRIBUTE_NAME: &str = "title";


const PRICE_REGEX: &str = r"(?<euros>[0-9]),(?<cents>[0-9]{2})";
const ALLERGEN_REGEX: &str = r"[A-Z]\w+";
const ADDITIVE_REGEX: &str = r"[0-9]{1,2}";

const E_MSG: &str = "HELP!";
const SELECTOR_PARSE_E_MSG: &str = "Error while parsing Selector string";
const REGEX_PARSE_E_MSG: &str = "Error while parsing regex string";

pub struct HTMLParser;

impl HTMLParser {
    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-114/HTMLParser> for more information

    pub const fn new() -> Self {
        Self
    }

    pub fn transform(&self, html: String) -> Vec<(Date, ParseCanteen)> {
        let document = Html::parse_document(&html);
        let root_node = Self::get_root_node(&document);
        let dates = Self::get_dates(&root_node);

        let mut canteens = Vec::new();
        for day_node in Self::get_day_nodes(&root_node) {
            let mut lines: Vec<ParseLine> = Vec::new();
            for line_node in Self::get_line_nodes(&day_node) {
                let mut dishes: Vec<Dish> = Vec::new();
                for dish_node in Self::get_dish_nodes(&line_node) {
                    let dish = Dish {
                        name: Self::get_dish_name(&dish_node),
                        price: Self::get_dish_price(&dish_node),
                        allergens: Self::get_dish_allergens(&dish_node),
                        additives: Self::get_dish_additives(&dish_node),
                        meal_type: Self::get_dish_type(&dish_node),
                        is_side: Self::is_dish_side(&Self::get_dish_price(&dish_node)),
                        env_score: Self::get_dish_env_score(&dish_node),
                    };
                    dishes.push(dish);
                }
                let line = ParseLine {
                    name: Self::get_line_name(&line_node),
                    dishes,
                };
                lines.push(line);
            }
            let canteen = ParseCanteen {
                name: Self::get_canteen_name(&root_node),
                lines,
            };
            canteens.push(canteen);
        }
        dates.into_iter().zip(canteens.into_iter()).collect()
    }

    fn get_root_node(document: &Html) -> ElementRef {
        let selector = Selector::parse(ROOT_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let root_node = document
            .select(&selector)
            .next()
            .expect(SELECTOR_PARSE_E_MSG);
        root_node
    }

    fn get_day_nodes<'a>(root_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(DAY_CLASS).expect(SELECTOR_PARSE_E_MSG);
        root_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_line_nodes<'a>(day_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(LINE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        day_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_dish_nodes<'a>(line_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let mut dish_nodes = Vec::new();
        for i in 0..8 {
            let selector =
                Selector::parse(&format!("{DISH_CLASS}{i}")).expect(SELECTOR_PARSE_E_MSG);
            dish_nodes.append(&mut line_node.select(&selector).collect::<Vec<_>>());
        }
        dish_nodes
    }

    fn get_dates(root_node: &ElementRef) -> Vec<Date> {
        let selector = Selector::parse(DAY_DATE_SUPER_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let date_node = root_node.select(&selector).next().expect(E_MSG);
        let selector = Selector::parse(DAY_DATE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let mut dates = Vec::new();
        for element in date_node.select(&selector) {
            let date_string = element.value().attr(DAY_DATE_ATTRIBUTE_NAME).expect(E_MSG);
            dates.push(Date::parse_from_str(date_string, DATE_FORMAT).expect(E_MSG));
        }
        dates
    }

    fn get_canteen_name(root_node: &ElementRef) -> String {
        let selector = Selector::parse(CANTEEN_NAME_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let canteen_name = root_node
            .select(&selector)
            .next()
            .expect(E_MSG)
            .inner_html();
        canteen_name
    }

    fn get_line_name(line_node: &ElementRef) -> String {
        let selector = Selector::parse(LINE_NAME_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let line_name: String = line_node
            .select(&selector)
            .next()
            .expect(E_MSG)
            .text()
            .map(|x| format!("{x} "))
            .collect();
        line_name.trim().to_owned()
    }

    fn get_dish_name(dish_node: &ElementRef) -> String {
        let selector = Selector::parse(DISH_NAME_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let dish_name: String = dish_node
            .select(&selector)
            .next()
            .expect(E_MSG)
            .text()
            .collect();
        let words: Vec<_> = dish_name.split_whitespace().collect();
        words.join(" ").trim().to_owned()
    }

    fn get_dish_price(dish_node: &ElementRef) -> Price {
        let mut prices: [u32; 4] = [0; 4];
        for i in 1..5 {
            let selector =
                Selector::parse(&format!("{DISH_PRICE_CLASS}{i}")).expect(SELECTOR_PARSE_E_MSG);
            let price_string: String = dish_node
                .select(&selector)
                .next()
                .expect(E_MSG)
                .inner_html();
            if price_string.is_empty() {
                prices[i - 1] = 0;
                continue;
            }
            
            let regex = Regex::new(PRICE_REGEX).expect(REGEX_PARSE_E_MSG);
            let capture = regex.captures(&price_string).expect(E_MSG);
            prices[i - 1] = format!("{}{}", &capture["euros"], &capture["cents"])
                .parse::<u32>()
                .expect(E_MSG);
        }
        Price {
            price_student: prices[0],
            price_guest: prices[1],
            price_employee: prices[2],
            price_pupil: prices[3],
        }
    }

    fn get_dish_allergens(dish_node: &ElementRef) -> Vec<Allergen> {
        let selector = Selector::parse(DISH_INFO_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let allergens_node = dish_node.select(&selector).next();
        if allergens_node.is_none() {
            return vec![];
        }
        let allergens_raw = allergens_node.expect(E_MSG).inner_html();
        let regex = Regex::new(ALLERGEN_REGEX).expect(REGEX_PARSE_E_MSG);
            regex.find_iter(&allergens_raw).filter_map(|a| Allergen::parse(a.as_str())).collect()
    }

    fn get_dish_additives(dish_node: &ElementRef) -> Vec<Additive> {
        let selector = Selector::parse(DISH_INFO_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let additives_node = dish_node.select(&selector).next();
        if additives_node.is_none() {
            return vec![];
        }
        let additives_raw = additives_node.expect(E_MSG).inner_html();
        let regex = Regex::new(ADDITIVE_REGEX).expect(REGEX_PARSE_E_MSG);
            regex.find_iter(&additives_raw).filter_map(|a| Additive::parse(a.as_str())).collect()
    }

    fn get_dish_type(dish_node: &ElementRef) -> MealType {
        let selector = Selector::parse(DISH_TYPE_NODE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let dish_type_nodes = dish_node.select(&selector).collect::<Vec<_>>();
        for dish_type_node in dish_type_nodes {
            let title = dish_type_node.value().attr(DISH_TYPE_ATTRIBUTE_NAME).expect(E_MSG);
            let dish_type = MealType::parse(title);
            if dish_type != MealType::Unknown {
                return dish_type;
            }
        }
        MealType::Unknown
    }

    const fn is_dish_side(price: &Price) -> bool {
        price.price_student <= 100  //TODO: More sophisticated method of telling meals and sides apart
    }

    fn get_dish_env_score(dish_node: &ElementRef) -> u32 {
        let selector = Selector::parse(ENV_SCORE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let env_score_node = dish_node.select(&selector).next();
        env_score_node.map_or(0, |x| x.value().attr(ENV_SCORE_ATTRIBUTE_NAME).expect(E_MSG).parse::<u32>().expect(E_MSG)) 
    }
}

#[cfg(test)]
mod tests {
    use crate::layer::data::swka_parser::html_parser::HTMLParser;

    #[tokio::test]
    async fn test_normal() {
        test_html(include_str!("./tests/test_normal.html"));
    }

    #[tokio::test]
    async fn test_no_meal_data() {
        test_html(include_str!("./tests/test_no_meal_data.html"));
    }

    #[tokio::test]
    async fn test_no_mealplan_shown() {
        test_html(include_str!("./tests/test_no_mealplan_shown.html"));
    }

    #[tokio::test]
    async fn test_mensa_moltke() {
        test_html(include_str!("./tests/test_mensa_moltke.html"));
    }

    fn test_html(path: &str) {
        let file_content = String::from(path);
        let parser = HTMLParser::new();
        let canteen_data = parser.transform(file_content);
        for canteen_date in canteen_data {
            println!("{}\n{}", canteen_date.0, canteen_date.1);
        }
    }
}
