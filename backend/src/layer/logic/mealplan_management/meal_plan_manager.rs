use async_trait::async_trait;
use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::MealplanManagementDataAccess;

struct MealPlanManager<DataAccess, Parser>
where
    DataAccess: MealplanManagementDataAccess,
    Parser: MealplanParser,
{
    db: DataAccess,
    parser: Parser,
}

impl<DataAccess, Parser> MealPlanManager<DataAccess, Parser>
where
    DataAccess: MealplanManagementDataAccess,
    Parser: MealplanParser,
{

    pub fn new(database: DataAccess, meal_plan_parser: Parser) -> Self {
        Self {
            db: database,
            parser: meal_plan_parser,
        }
    }
}

#[async_trait]
impl<DataAccess, Parser> MensaParseScheduling for MealPlanManager<DataAccess, Parser>
where
    DataAccess: MealplanManagementDataAccess,
    Parser: MealplanParser,
{
    async fn start_update_parsing() {
        todo!()

    }

    async fn start_full_parsing() {
        todo!()
    }
}
