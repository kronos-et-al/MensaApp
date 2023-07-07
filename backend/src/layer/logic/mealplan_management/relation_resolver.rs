use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::model::Canteen;
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::util::Date;
use std::error::Error;
use std::future::Future;
use std::io::empty;

struct RelationResolver {
    db: dyn MealplanManagementDataAccess,
}

impl RelationResolver {
    /// TODO fix size issue
    pub fn new(database: Box<dyn MealplanManagementDataAccess>) -> Box<RelationResolver> {
        RelationResolver { db: database };
        todo!()
    }

    pub async fn resolve(&self, canteen: ParseCanteen, date: Date) {
        //Todo return only one similar canteen form database
        let similar_canteens_result = self.db.get_similar_canteens(canteen.name).await;
        let similar_canteen = match similar_canteens_result {
            Ok(sim_canteen) => Self.insert_canteen(sim_canteen, canteen),
            Err(e) => panic!("Database error occurred: {:?}", e),
        };

        for line in canteen.lines {
            for dish in line.dishes {}
        }
    }

    async fn insert_canteen(
        &self,
        similar_canteen: Option<Canteen>,
        fallback: ParseCanteen,
    ) -> Result<Canteen, ()> {
        match similar_canteen {
            Some(similar) => match Self.db.update_canteen(similar.id, fallback.name) {
                Ok(updated_canteen) => Ok(updated_canteen),
                Err(e) => Err(Self.print_error(e)),
            },
            None => match Self.db.insert_canteen(fallback.name) {
                Ok(inserted_canteen) => Ok(inserted_canteen),
                Err(e) => Err(Self.print_error(e)),
            },
        }
    }

    fn print_error(&self, e: DataError) {
        panic!("Database error occurred: {:?}", e);
    }
}
