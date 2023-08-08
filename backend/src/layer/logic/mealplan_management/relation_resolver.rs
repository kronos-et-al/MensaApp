use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::util::{Date, Uuid};
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

    const SIDE_PERCENTAGE_GAP: f64 = 0.8;
    const EDGE_CASE_NAME: &'static str = "je 100 g";

    /// This method resolves relation problems with canteen data and the corresponding database.<br>
    /// After each resolve the object gets injected into the database.<br>
    /// If an similar object already exists, the existing object will be updated with the new object data.<br>
    /// `canteen: ParseCanteen`<br>This struct contains all canteen data e.g. lines and dishes.<br>
    /// `date: Date`<br>This date decides when the meal will be served next.<br>
    /// # Errors
    /// Occurring errors get passed to the [`MealPlanManager`](`crate::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager`)
    pub async fn resolve(&self, canteen: ParseCanteen, date: Date) -> Result<(), DataError> {
        let db_canteen = match self.db.get_similar_canteen(&canteen.name).await? {
            Some(similar_canteen) => {
                self.db
                    .update_canteen(similar_canteen, &canteen.name, canteen.pos)
                    .await?;
                similar_canteen
            }
            None => self.db.insert_canteen(&canteen.name, canteen.pos).await?,
        };
        self.db.dissolve_relations(db_canteen, date).await?;
        for line in canteen.lines {
            let name = &line.name.clone();
            if let Err(e) = self.resolve_line(date, line, db_canteen).await {
                warn!("Skip line '{name}' as it could not be resolved: {e}");
            }
        }
        Ok(())
    }

    async fn resolve_line(
        &self,
        date: Date,
        line: ParseLine,
        canteen_id: Uuid,
    ) -> Result<(), DataError> {
        let line_id = match self.db.get_similar_line(&line.name, canteen_id).await? {
            Some(similar_line) => {
                self.db
                    .update_line(similar_line, &line.name, line.pos)
                    .await?;
                similar_line
            }
            None => {
                self.db
                    .insert_line(canteen_id, &line.name, line.pos)
                    .await?
            }
        };

        let average = Self::average(line.dishes.iter());

        for dish in line.dishes {
            let name = &dish.name.clone();
            if let Err(e) = self.resolve_dish(line_id, date, dish, average).await {
                warn!("Skip dish '{name}' as it could not be resolved: {e}");
            }
        }
        Ok(())
    }

    async fn resolve_dish(
        &self,
        line_id: Uuid,
        date: Date,
        dish: Dish,
        average: f64,
    ) -> Result<(), DataError> {
        let similar_meal_result = self
            .db
            .get_similar_meal(&dish.name, &dish.allergens, &dish.additives)
            .await?;
        let similar_side_result = self
            .db
            .get_similar_side(&dish.name, &dish.allergens, &dish.additives)
            .await?;

        // Case 1.1: A similar side and meal could be found. Uncommon case.
        // Case 1.2: Or just a meal could be found.
        if let Some(similar_meal) = similar_meal_result {
            self.db.update_meal(similar_meal, &dish.name).await?;
            self.db
                .add_meal_to_plan(similar_meal, line_id, date, dish.price)
                .await?;
        // Case 2: A similar side could be found.
        } else if let Some(similar_side) = similar_side_result {
            self.db.update_side(similar_side, &dish.name).await?;
            self.db
                .add_side_to_plan(similar_side, line_id, date, dish.price)
                .await?;
        // Case 3: No similar meal could be found. Dish needs to be determined.
        } else if Self::is_side(dish.price.price_student, average, &dish.name) {
            let side_id = self
                .db
                .insert_side(&dish.name, dish.meal_type, &dish.allergens, &dish.additives)
                .await?;
            self.db
                .add_side_to_plan(side_id, line_id, date, dish.price)
                .await?;
        } else {
            let meal_id = self
                .db
                .insert_meal(&dish.name, dish.meal_type, &dish.allergens, &dish.additives)
                .await?;
            self.db
                .add_meal_to_plan(meal_id, line_id, date, dish.price)
                .await?;
        };
        Ok(())
    }

    fn is_side(dish_price: u32, average: f64, dish_name: &str) -> bool {
        let price_limit = average * Self::SIDE_PERCENTAGE_GAP;
        (f64::from(dish_price)) < price_limit && !dish_name.contains(Self::EDGE_CASE_NAME)
    }

    fn average(dishes: Iter<Dish>) -> f64 {
        let len = u32::try_from(dishes.len())
            .expect("RelationResolver.average: usize could not be casted to u32");
        let sum: u32 = dishes.map(|dish| dish.price.price_student).sum();

        f64::from(sum.checked_div(len).unwrap_or_default())
    }
}

#[cfg(test)]
mod test {
    use crate::interface::mensa_parser::model::{Dish, ParseCanteen, ParseLine};
    use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
    use crate::layer::logic::mealplan_management::test::mealplan_management_database_mock::MealplanManagementDatabaseMock;
    use crate::util::{MealType, Price};
    use chrono::Local;
    use rand::{self, Rng};
    use uuid::Uuid;

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
            env_score: 0,
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
            env_score: 0,
        }
    }

    fn get_line(dishes: Vec<Dish>) -> ParseLine {
        ParseLine {
            name: "test_line".to_string(),
            dishes,
            pos: 42_u32,
        }
    }

    fn get_canteen(lines: Vec<ParseLine>) -> ParseCanteen {
        ParseCanteen {
            name: "test_canteen".to_string(),
            lines,
            pos: 42_u32,
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
    async fn test_resolve_empty_canteen() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let res = resolver.resolve(get_empty_canteen(), Local::now().date_naive());
        assert!(res.await.is_ok());
    }

    #[tokio::test]
    async fn test_resolve_canteens() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let mut rng = rand::thread_rng();
        for canteen in get_canteens(
            rng.gen_range(1..=10),
            rng.gen_range(1..=10),
            rng.gen_range(1..=10),
        ) {
            assert!(resolver
                .resolve(canteen, Local::now().date_naive())
                .await
                .is_ok());
        }
    }

    #[tokio::test]
    async fn test_resolve_line_with_rand_dishes() {
        let resolver = RelationResolver::new(MealplanManagementDatabaseMock);
        let mut rng = rand::thread_rng();
        let mut dishes = Vec::new();
        for _ in 0..6 {
            dishes.push(get_dish_with_price(rng.gen_range(80..=400)));
        }
        let line = get_line(dishes);
        assert!(resolver
            .resolve_line(Local::now().date_naive(), line, Uuid::default())
            .await
            .is_ok());
    }

    #[test]
    fn test_is_side() {
        let res =
            RelationResolver::<MealplanManagementDatabaseMock>::is_side(400_u32, 400_f64, "name");
        assert!(!res);
    }

    #[test]
    fn test_average_calc() {
        let prices = vec![300, 455, 205, 660, 220, 880];
        let mut dishes = Vec::new();
        for i in prices {
            dishes.push(get_dish_with_price(i));
        }
        let average = RelationResolver::<MealplanManagementDatabaseMock>::average(dishes.iter());
        assert!(450.0 < average);
        assert!(460.0 > average);

        let dishes = vec![];
        let average = RelationResolver::<MealplanManagementDatabaseMock>::average(dishes.iter());
        assert!((average - 0.0).abs() < f64::EPSILON);
    }
}
