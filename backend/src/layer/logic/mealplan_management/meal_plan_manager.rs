use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::MealplanManagementDataAccess;
use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
use async_trait::async_trait;

struct MealPlanManager<Parser, DataAccess>
where
    Parser: MealplanParser,
    DataAccess: MealplanManagementDataAccess,
{
    resolver: RelationResolver<DataAccess>,
    parser: Parser,
}

impl<Parser, DataAccess> MealPlanManager<Parser, DataAccess>
where
    DataAccess: MealplanManagementDataAccess,
    Parser: MealplanParser,
{
    pub fn new(database: DataAccess, meal_plan_parser: Parser) -> Self {
        Self {
            resolver: RelationResolver { db: database },
            parser: meal_plan_parser,
        }
    }
}

#[async_trait]
impl<DataAccess, Parser> MensaParseScheduling for MealPlanManager<Parser, DataAccess>
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
