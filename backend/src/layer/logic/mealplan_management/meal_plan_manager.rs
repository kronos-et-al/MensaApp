use async_trait::async_trait;

use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::MealplanManagementDataAccess;

struct MealPlanManager {
    db: Box<dyn MealplanManagementDataAccess>,
    parser: Box<dyn MealplanParser>,
}

impl MealPlanManager {
    pub fn new(database: Box<dyn MealplanManagementDataAccess>, meal_plan_parser: Box<dyn MealplanParser>) -> Box<MealPlanManager> {
        let mp = MealPlanManager {
            db: database,
            parser: meal_plan_parser
        };
        todo!()
    }
}

#[async_trait]
impl MensaParseScheduling for MealPlanManager {
    async fn start_update_parsing() {
        todo!()
    }

    async fn start_full_parsing() {
        todo!()
    }
}