use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::util::Date;
use scraper::{Html, Selector, ElementRef};

const ROOT: &str = "div.main-content";
const MENSA_NAME: &str = "h1.mensa_fullname";


pub struct HTMLParser;

impl HTMLParser {
    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-114/HTMLParser> for more information

    pub const fn new() -> Self {
        Self
    }

    pub fn transform(&self, html: String) -> Vec<(Date, ParseCanteen)> {
        let document = Html::parse_document(&html);
        let root_node = Self::get_root_node(&document);

        todo!()

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
    }

    fn get_root_node(document: &Html) -> ElementRef {
        let selector = Selector::parse(ROOT).expect("HELP!");
        let root_node = document.select(&selector).next().expect("HELP!");
        root_node
    }

    fn get_line_node(&self, html: String) -> ElementRef {
        todo!()
    }

    fn get_dish_node(&self, html: String) -> ElementRef {
        todo!()
    }

    fn transform_to_dish(&self, dish_as_string: String) -> Dish {
        todo!()

        //skip isSide = false
    }

    fn transform_to_line(&self, line_name: String, dishes: Vec<Dish>) -> ParseLine {
        todo!()
    }

    fn transform_to_canteen(&self, canteen_name: String, lines: Vec<ParseLine>) -> ParseCanteen {
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
