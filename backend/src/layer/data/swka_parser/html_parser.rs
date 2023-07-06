use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::util::Date;

pub struct HTMLParser;

impl HTMLParser {

    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-114/HTMLParser> for more information

    pub fn new() -> HTMLParser {
        Self
    }

    pub fn transform(&self, html: String) -> Vec<(Date, ParseCanteen)> {
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

    fn get_lines(&self, html: String) -> Vec<String> {
        todo!()
    }

    fn get_dishes(&self, html: String) -> Vec<String> {
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