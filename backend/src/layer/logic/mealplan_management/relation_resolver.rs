use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::MealplanManagementDataAccess;
use crate::util::Date;

struct RelationResolver {
    db: dyn MealplanManagementDataAccess
}

impl RelationResolver {

    /// TODO fix size issue
    pub fn new(db: Box<dyn MealplanManagementDataAccess>) -> Box<RelationResolver> {
        RelationResolver {
            db: database
        };
        todo!()
    }

    pub fn resolve(&self, canteen: ParseCanteen, date: Date) {
        todo!()
    }



}