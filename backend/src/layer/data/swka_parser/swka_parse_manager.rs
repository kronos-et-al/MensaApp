use crate::interface::mensa_parser::MealplanParser;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::model::Canteen;
use crate::util::Date;
use async_trait::async_trait;

struct SwKaParseManager;


impl SwKaParseManager {
    pub fn new() -> SwKaParseManager {
        Self
    }
}

#[async_trait]
impl MealplanParser for SwKaParseManager{
    //TODO Impl parse(day: Date) -> Vec<ParseCanteen>
    async fn parse(&self, day: Date) -> Vec<ParseCanteen> {
        todo!()
    }
    //TODO Impl parse_all() -> Vec<(Date, Vec<Canteen>)>
    async fn parse_all(&self) -> Vec<(Date, Vec<ParseCanteen>)> {
        todo!()
    }
}