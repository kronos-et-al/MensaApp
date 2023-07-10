use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::{DataError, MealplanManagementDataAccess};
use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
use async_trait::async_trait;
use chrono::{NaiveDate, Utc};
use chrono::format::parse;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::layer::logic::mealplan_management::util::{error_canteen_resolved, trace_canteen_resolved};

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
    async fn start_update_parsing(&self) {
        let date = Utc::now().date_naive();

        for parse_canteen in self.parser.parse(date).await {
            match self.resolver.resolve(parse_canteen, date).await {
                Ok(canteen) => trace_canteen_resolved(&parse_canteen.name),
                Err(e) => error_canteen_resolved(&parse_canteen.name, e)
            }
        }
    }

    async fn start_full_parsing(&self) {
        let date = Utc::now().date_naive();
        let parse_tuples = self.parser.parse_all().await;
        for (date, parse_canteens) in parse_tuples {
            for parse_canteen in parse_canteens {
                match self.resolver.resolve(parse_canteen, date).await {
                    Ok(canteen) => trace_canteen_resolved(&parse_canteen.name),
                    Err(e) => error_canteen_resolved(&parse_canteen.name, e)
                }
            }
        }
    }
}
