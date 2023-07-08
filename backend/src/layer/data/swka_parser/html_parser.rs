use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::util::{Date, Price, Allergen, Additive, MealType};
use regex::Regex;
use scraper::{ElementRef, Html, Selector};

const ROOT: &str = "div.main-content";
const CANTEEN_NAME: &str = "h1.mensa_fullname";

const DAY_CLASS: &str = "div.canteen-day";
const DAY_DATE_CLASS: &str = "ul.canteen-day-nav";

const LINE_CLASS: &str = "tr.mensatype_rows";
const LINE_NAME: &str = "td.mensatype";

const DISH_CLASS: &str = "tr.mt-{}";
const DISH_NAME: &str = "span.bg";
const DISH_PRICE: &str = "span.bgp.price_";

const SELECTOR_PARSE_E_MSG: &str = "Error while parsing Selector string";

pub struct HTMLParser;

impl HTMLParser {
    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-114/HTMLParser> for more information

    pub const fn new() -> Self {
        Self
    }

    pub fn transform(&self, html: String) -> Vec<(Date, ParseCanteen)> {
        let document = Html::parse_document(&html);
        let root_node = Self::get_root_node(&document);
        let canteen_name = Self::get_canteen_name(&root_node);

        let mut canteens_and_dates = Vec::new();
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
                        is_side: Self::is_dish_side(&dish_node),
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
                name: String::from(&canteen_name),
                lines,
            };
            canteens_and_dates.push((Self::get_date(&root_node, &day_node).expect("HELP!"), canteen));
        }
        canteens_and_dates
    }

    fn get_root_node(document: &Html) -> ElementRef {
        let selector = Selector::parse(ROOT).expect("HELP!");
        let root_node = document.select(&selector).next().expect(SELECTOR_PARSE_E_MSG);
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
            let selector = Selector::parse(&format!("tr.mt-{i}")).expect(SELECTOR_PARSE_E_MSG);
            dish_nodes.append(&mut line_node.select(&selector).collect::<Vec<_>>());
        }
        dish_nodes
    }

    fn get_date(root_node: &ElementRef, day_node: &ElementRef) -> Option<Date> {
        let day_id = day_node.value().attr("id").expect("HELP!");
        let day_number = &day_id[day_id.len()-1..];
        let day_nav_id = format!("{}nav_{day_number}", &day_id[..day_id.len()-1]);

        let selector = Selector::parse(DAY_DATE_CLASS).expect(SELECTOR_PARSE_E_MSG);
        let day_node = root_node.select(&selector).next().expect("HELP!");
        let selector = Selector::parse("a").expect("HELP!");
        for day in day_node.select(&selector) {
            if day.value().attr("id").expect("HELP").eq(&day_nav_id){
                let date = day.value().attr("rel").expect("HELP!");
                return Some(Date::parse_from_str(date, "%Y-%m-%d").expect("HELP!"));
            }
        }
        None
    }

    fn get_canteen_name(root_node: &ElementRef) -> String {
        let selector = Selector::parse(CANTEEN_NAME).expect(SELECTOR_PARSE_E_MSG);
        let canteen_name = root_node
            .select(&selector)
            .next()
            .expect("HELP!")
            .inner_html();
        canteen_name
    }

    fn get_line_name(line_node: &ElementRef) -> String {
        let selector = Selector::parse(LINE_NAME).expect(SELECTOR_PARSE_E_MSG);
        let line_name: String = line_node
            .select(&selector)
            .next()
            .expect("HELP!")
            .text()
            .map(|x| format!("{x} "))
            .collect();
        line_name.trim().to_owned()
    }

    fn get_dish_name(dish_node: &ElementRef) -> String {
        let selector = Selector::parse(DISH_NAME).expect(SELECTOR_PARSE_E_MSG);
        let dish_name: String = dish_node
            .select(&selector)
            .next()
            .expect("HELP!")
            .text()
            .collect();
        let words: Vec<_> = dish_name.split_whitespace().collect();
        words.join(" ").trim().to_owned()
    }

    fn get_dish_price(dish_node: &ElementRef) -> Price {
        let mut prices: [u32; 4] = [0; 4];
        for i in 1..5 {
            let selector = Selector::parse(&format!("{DISH_PRICE}{i}")).expect(SELECTOR_PARSE_E_MSG);
            let regex = Regex::new(r"(?<euros>[0-9]),(?<cents>[0-9]{2})").expect("HELP!");
            let price_string: String = dish_node.select(&selector).next().expect("HELP!").inner_html();
            let capture = regex.captures(&price_string).expect("HELP!");
            let price = format!("{}{}", &capture["euros"], &capture["cents"]).parse::<u32>().expect("HELP!");
            prices[i-1] = price;
        }
        Price {
            price_student: prices[0],
            price_guest: prices[1],
            price_employee: prices[2],
            price_pupil: prices[3],
        }
    }

    fn get_dish_allergens(dish_node: &ElementRef) -> Vec<Allergen> {
        vec![]
    }

    fn get_dish_additives(dish_node: &ElementRef) -> Vec<Additive> {
        vec![]
    }

    fn get_dish_type(dish_node: &ElementRef) -> MealType {
        todo!()
    }

    fn is_dish_side(dish_node: &ElementRef) -> bool {
        todo!()
    }

    fn get_dish_env_score(dish_node: &ElementRef) -> u32 {
        todo!()
    }


    // Use maps to determine allergens and additives for dish?
}

#[cfg(test)]
mod tests {
    use crate::layer::data::swka_parser::html_parser::HTMLParser;

    #[tokio::test]
    async fn test_html() {
        let file_content = String::from(include_str!("test.html"));
        let parser = HTMLParser::new();
        parser.transform(file_content);
    }
}
