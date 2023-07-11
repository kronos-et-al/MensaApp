use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::util::Date;

pub struct RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
{
    db: DataAccess,
}


impl<DataAccess> RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
{
    pub fn new(db: DataAccess) -> Self {
        Self {
            db
        }
    }
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

        // handle line, handle dish
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
                if let Some(similar_meal) = similar_meal_result {
                    self.db.update_meal(similar_meal.id, db_line.id, date, &dish.name, &dish.price).await?;
                    // A similar side could be found
                } else if let Some(similar_side) = similar_side_result {
                    self.db.update_side(similar_side.id, db_line.id, date, &dish.name, &dish.price).await?;
                    // No similar meal could be found. Dish needs to be determined

                    //Maybe-TODO better solution for this case. This should work also
                    // 80% vom durchschnitt der gerichte. alles darunter = side
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
    use chrono::Utc;
    use rand::{self, Rng};
    use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
    use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
    use crate::layer::logic::mealplan_management::test::mealplan_management_database_mock::MealplanManagementDatabaseMock;
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

    fn get_empty_canteen() -> ParseCanteen {
        get_canteen(Vec::new())
    }

    #[tokio::test]
    async fn resolve_empty_canteen() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let res = resolver.resolve(get_empty_canteen(), Utc::now().date_naive());
        assert!(res.await.is_ok());
    }

    #[tokio::test]
    async fn resolve_canteens() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let mut rng = rand::thread_rng();
        for canteen in get_canteens(rng.gen_range(1..=10), rng.gen_range(1..=10), rng.gen_range(1..=10)) {
            assert!(resolver.resolve(canteen, Utc::now().date_naive()).await.is_ok());
        }
    }
}
