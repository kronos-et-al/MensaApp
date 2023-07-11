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

    /// This method resolves relation problems with canteen data and the corresponding database.<br>
    /// After each resolve the object gets injected into the database.<br>
    /// If an similar object already exists, the existing object will be updated with the new object data.<br>
    /// `canteen: ParseCanteen`<br>This struct contains all canteen data e.g. lines and dishes.<br>
    /// `date: Date`<br>This date decides when the meal will be served next.<br>
    /// **Return**<br>Occurring errors get passed to the `MealPlanManger`.
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

#[cfg(test)]
mod test {
    use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
    use crate::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager;
    use crate::util::{MealType, Price};

    fn get_dish() -> Dish {
        Dish {
            name: "test_dish".to_string(),
            price: Price {
                price_student: 0,
                price_employee: 0,
                price_guest: 0,
                price_pupil: 0,
            },
            allergens: vec![],
            additives: vec![],
            meal_type: MealType::Vegan,
        }
    }

    fn get_line(dishes: Vec<Dish>) -> ParseLine {
        ParseLine {
            name: "test_line".to_string(),
            dishes,
        }
    }

    fn get_canteen(lines: Vec<ParseLine>) -> ParseCanteen {
        ParseCanteen {
            name: "test_canteen".to_string(),
            lines,
        }
    }

    fn get_canteens(amount_canteens: u32, amount_lines: u32, amount_dishes: u32) -> Vec<ParseCanteen> {
        let mut canteens = Vec::new();
        for _ in 0..amount_canteens {
            let mut lines = Vec::new();
            for _ in 0..amount_lines {
                let mut dishes = Vec::new();
                for _ in 0..amount_dishes {
                    dishes.push(get_dish());
                }
                lines.push(get_line(dishes));
            }
            canteens.push(get_canteen(lines));
        }
        canteens
    }

    fn get_meal_plan_manager() -> MealPlanManager<Parser, DataAccess> {
        MealPlanManager::_new(MealplanManagementDatabaseMock {}, MealPlanParserMock {})
        todo!()
    }

    #[test]
    fn resolve_empty_canteen() {
        // resolve(get_canteens(1, 0, 0).pop(), Utc::now().date_naive());
        // !assert_eq!()
    }

    #[test]
    fn resolve_canteen() {
        // resolve(get_canteens(1, 0, 0).pop(), Utc::now().date_naive());
        // !assert_eq!()
    }
}
