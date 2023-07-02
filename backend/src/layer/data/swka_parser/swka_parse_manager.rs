use crate::interface::mensa_parser::MealplanParser;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::model::Canteen;
use crate::util::Date;

struct SwKaParseManager;


impl SwKaParseManager {
    pub fn new() -> SwKaParseManager {
        SwKaParseManager
    }
}

impl MealplanParser for SwKaParseManager{
    //TODO Impl parse(day: Date) -> Vec<ParseCanteen>
    fn parse(day: Date) -> Vec<ParseCanteen> {
        OK()
    }
    //TODO Impl parse_all() -> Vec<(Date, Vec<Canteen>)>
    fn parse_all() -> Vec<(Date, Vec<Canteen>)> {
        OK()
    }
}