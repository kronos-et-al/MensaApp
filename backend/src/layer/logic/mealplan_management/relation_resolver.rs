use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::MealplanManagementDataAccess;
use crate::util::Date;

struct RelationResolver {
    db: Box<dyn MealplanManagementDataAccess>,
}

impl RelationResolver {

    pub fn new(db: Box<dyn MealplanManagementDataAccess>) -> Box<RelationResolver> {
        RelationResolver {
            db,
        };
        todo!()
    }

    pub fn resolve(&self, canteen: ParseCanteen, date: Date) {
        todo!()
    }



}