use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::util::Date;

pub struct RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
{
    pub(crate) db: DataAccess,
}

impl<DataAccess> RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
{
    const fn get_edge_case_meal() -> &'static str {"je 100 g"}

    pub async fn resolve(&self, canteen: ParseCanteen, date: Date) -> Result<(), DataError>{
        match self.db.get_similar_canteen(&canteen.name).await? {
            Some(similar_canteen) => self.db.update_canteen(similar_canteen.id, &canteen.name).await?,
            None => self.db.insert_canteen(&canteen.name).await?
        };

        for line in canteen.lines {
            let db_line = match self.db.get_similar_line(&line.name).await? {
                Some(similar_line) => self.db.update_line(similar_line.id, &line.name).await?,
                None => self.db.insert_line(&line.name).await?
             };

            for dish in line.dishes {
                let similar_meal_result = self.db.get_similar_meal(&dish.name).await?;
                let similar_side_result = self.db.get_similar_side(&dish.name).await?;
                // A similar side and meal could be found. Uncommon case.
                // Or just a meal could be found.
                if similar_meal_result.is_some() {
                    //Maybe-TODO get a better solution for .expect
                    self.db.update_meal(similar_meal_result.expect("Cant fail, as meal.is_some?").id, db_line.id, date, &dish.name, &dish.price).await?;
                    // A similar side could be found
                } else if similar_side_result.is_some() {
                    //Maybe-TODO get a better solution for .expect
                    self.db.update_side(similar_side_result.expect("Cant fail; as side.is_some?").id, db_line.id, date, &dish.name, &dish.price).await?;
                    // No similar meal could be found. Dish needs to be determined

                    //Maybe-TODO better solution for this case. This should work also
                } else if dish.price.price_student < 150 && !dish.name.contains(Self::get_edge_case_meal()) {
                    self.db.insert_side(&dish.name, dish.meal_type, &dish.price, date, &dish.allergens, &dish.additives).await?;
                } else {
                    self.db.insert_meal(&dish.name, dish.meal_type, &dish.price, date, &dish.allergens, &dish.additives).await?;
                }
            }
        }
        Ok(())
    }
}
