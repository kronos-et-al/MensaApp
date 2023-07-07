use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::util::Date;
use scraper::{ElementRef, Html, Selector};

const ROOT: &str = "div.main-content";
const CANTEEN_NAME: &str = "h1.mensa_fullname";

const DAY_CLASS: &str = "div.canteen-day";
const DAY_DATE_CLASS: &str = "ul.canteen-day-nav";

const LINE_CLASS: &str = "tr.mensatype_rows";
const LINE_NAME: &str = "td.mensatype";

const DISH_CLASS: &str = "tr.mt-{}";
const DISH_NAME: &str = "span.bg";
const DISH_PRICE: &str = "span.bgp";

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
            let date = Self::get_date(&root_node, &day_node).expect("HELP!");
            let mut lines: Vec<ParseLine> = Vec::new();
            for line_node in Self::get_line_nodes(&day_node) {
                let line_name = Self::get_line_name(&line_node);
                let mut dishes: Vec<Dish> = Vec::new();
                for dish_node in Self::get_dish_nodes(&line_node) {}
                let line = ParseLine {
                    name: line_name,
                    dishes,
                };
                lines.push(line);
            }
            let canteen = ParseCanteen {
                name: String::from(&canteen_name),
                lines,
            };
            canteens_and_dates.push((date, canteen));
        }

        //Preprocessing and exceptions
        //for each date in HTML {
        //get_lines(html)
        //for each line in lines {
        //get_dishes(line)
        //for each dish in dishes {
        //transform_to_dish(dish_as_string)
        //}
        //transform_to_line(line_name, dishes)
        //add line to vec_lines
        //}
        //transform_to_canteen(canteen_name, lines)
        //vec.add(date, canteen)
        //}
        //return vec
        canteens_and_dates
    }

    fn get_root_node(document: &Html) -> ElementRef {
        let selector = Selector::parse(ROOT).expect("HELP!");
        let root_node = document.select(&selector).next().expect("HELP!");
        root_node
    }

    fn get_day_nodes<'a>(root_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(DAY_CLASS).expect("HELP!");
        root_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_line_nodes<'a>(day_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        let selector = Selector::parse(LINE_CLASS).expect("HELP!");
        day_node.select(&selector).collect::<Vec<_>>()
    }

    fn get_dish_nodes<'a>(line_node: &'a ElementRef<'a>) -> Vec<ElementRef<'a>> {
        //let selector = Selector::parse(DISH_CLASS).expect("HELP!");
        //line_node.select(&selector).collect::<Vec<_>>()
        todo!()
    }

    fn get_date(root_node: &ElementRef, day_node: &ElementRef) -> Option<Date> {
        let day_id = day_node.value().attr("id").expect("HELP!");
        let day_number = &day_id[day_id.len()-1..];
        let day_nav_id = format!("{}nav_{day_number}", &day_id[..day_id.len()-1]);

        let selector = Selector::parse(DAY_DATE_CLASS).expect("HELP!");
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
        let selector = Selector::parse(CANTEEN_NAME).expect("HELP!");
        let canteen_name = root_node
            .select(&selector)
            .next()
            .expect("HELP!")
            .inner_html();
        canteen_name
    }

    fn get_line_name(line_node: &ElementRef) -> String {
        let selector = Selector::parse(LINE_NAME).expect("HELP!");
        let line_name: String = line_node
            .select(&selector)
            .next()
            .expect("HELP!")
            .text()
            .map(|x| format!("{x} "))
            .collect();
        line_name.trim().to_owned()
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
