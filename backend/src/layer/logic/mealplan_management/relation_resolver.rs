use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::interface::persistent_data::model::Line;
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::util::Date;
use std::slice::Iter;
use tracing::warn;

pub struct RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess,
{
    db: DataAccess,
}

impl<DataAccess> RelationResolver<DataAccess>
where
    DataAccess: MealplanManagementDataAccess,
{
    pub const fn new(db: DataAccess) -> Self {
        Self { db }
    }

    const PERCENTAGE: f64 = 0.8;
    const fn get_edge_case_meal() -> &'static str {
        "je 100 g"
    }

    /// This method resolves relation problems with canteen data and the corresponding database.<br>
    /// After each resolve the object gets injected into the database.<br>
    /// If an similar object already exists, the existing object will be updated with the new object data.<br>
    /// `canteen: ParseCanteen`<br>This struct contains all canteen data e.g. lines and dishes.<br>
    /// `date: Date`<br>This date decides when the meal will be served next.<br>
    /// **Return**<br>Occurring errors get passed to the `MealPlanManger`.
    pub async fn resolve(&self, canteen: ParseCanteen, date: Date) -> Result<(), DataError> {
        match self.db.get_similar_canteen(&canteen.name).await? {
            Some(similar_canteen) => {
                self.db
                    .update_canteen(similar_canteen.id, &canteen.name)
                    .await?
            }
            None => self.db.insert_canteen(&canteen.name).await?,
        };

        for line in canteen.lines {
            let name = &line.name.clone();
            if let Err(_e) = self.resolve_line(line, date).await {
                warn!("Skip line '{:?}' as it could not be resolved", name);
            }
        }
        Ok(())
    }

    async fn resolve_line(&self, line: ParseLine, date: Date) -> Result<(), DataError> {
        let db_line = match self.db.get_similar_line(&line.name).await? {
            Some(similar_line) => self.db.update_line(similar_line.id, &line.name).await?,
            None => self.db.insert_line(&line.name).await?,
        };

        let average = Self::determine_average_price(line.dishes.iter(), line.dishes.len())?;

        for dish in line.dishes {
            let name = &dish.name.clone();
            if let Err(_e) = self.resolve_dish(&db_line, dish, date, average).await {
                warn!("Skip dish '{:?}' as it could not be resolved", name);
            }
        }
        Ok(())
    }

    async fn resolve_dish(
        &self,
        db_line: &Line,
        dish: Dish,
        date: Date,
        average: u32,
    ) -> Result<(), DataError> {
        let similar_meal_result = self.db.get_similar_meal(&dish.name).await?;
        let similar_side_result = self.db.get_similar_side(&dish.name).await?;
        let price_limit = f64::from(average) * Self::PERCENTAGE;

        // Case: A similar side and meal could be found. Uncommon case.
        // Case: Just a meal could be found.
        if let Some(similar_meal) = similar_meal_result {
            self.db
                .update_meal(similar_meal.id, db_line.id, date, &dish.name, &dish.price)
                .await?;
        // Case: A similar side could be found
        } else if let Some(similar_side) = similar_side_result {
            self.db
                .update_side(similar_side.id, db_line.id, date, &dish.name, &dish.price)
                .await?;
        // Case: No similar meal could be found. Dish needs to be determined
        } else if (f64::from(dish.price.price_student)) < price_limit
            && !dish.name.contains(Self::get_edge_case_meal())
        {
            self.db
                .insert_side(
                    &dish.name,
                    dish.meal_type,
                    &dish.price,
                    date,
                    &dish.allergens,
                    &dish.additives,
                )
                .await?;
        } else {
            self.db
                .insert_meal(
                    &dish.name,
                    dish.meal_type,
                    &dish.price,
                    date,
                    &dish.allergens,
                    &dish.additives,
                )
                .await?;
        };
        Ok(())
    }

    fn determine_average_price(dishes: Iter<Dish>, len: usize) -> Result<u32, DataError> {
        let mut sum: u32 = 0;
        for dish in dishes {
            sum += dish.price.price_student;
        }
        match u32::try_from(len) {
            Ok(len) => Ok(sum / len),
            Err(_e) => {
                warn!("A calculation error occurred");
                Err(DataError::CalculationError)
            }
        }
    }
}

#[cfg(test)]
mod test {
    use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
    use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
    use crate::layer::logic::mealplan_management::test::mealplan_management_database_mock::MealplanManagementDatabaseMock;
    use crate::util::{MealType, Price};
    use chrono::Utc;
    use rand::{self, Rng};

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

    fn get_dish_with_price(price: u32) -> Dish {
        Dish {
            name: "test_dish".to_string(),
            price: Price {
                price_student: price,
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

    fn get_canteens(
        amount_canteens: u32,
        amount_lines: u32,
        amount_dishes: u32,
    ) -> Vec<ParseCanteen> {
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
        for canteen in get_canteens(
            rng.gen_range(1..=10),
            rng.gen_range(1..=10),
            rng.gen_range(1..=10),
        ) {
            assert!(resolver
                .resolve(canteen, Utc::now().date_naive())
                .await
                .is_ok());
        }
    }

    #[tokio::test]
    async fn resolve_line_with_rand_dishes() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let mut rng = rand::thread_rng();
        let mut dishes = Vec::new();
        for _ in 0..6 {
            dishes.push(get_dish_with_price(rng.gen_range(80..=400)));
        }
        let line = get_line(dishes);
        assert!(resolver
            .resolve_line(line, Utc::now().date_naive())
            .await
            .is_ok());
    }

    #[test]
    fn test_average_calc() {
        let prices = vec![300, 455, 205, 660, 220, 880];
        let mut dishes = Vec::new();
        for i in 0..6 {
            dishes.push(get_dish_with_price(prices[i]));
        }
        if let Ok(average) =
            RelationResolver::<MealplanManagementDatabaseMock>::determine_average_price(
                dishes.iter(),
                dishes.len(),
            )
        {
            assert!(450 < average);
            assert!(460 > average);
        };
    }
}
