use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::{MealplanManagementDataAccess};
use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
use async_trait::async_trait;
use chrono::{Utc};
use crate::layer::logic::mealplan_management::util::{error_canteen_resolved, trace_canteen_resolved};

struct MealPlanManager<Parser, DataAccess>
where
    Parser: MealplanParser + Send + Sync,
    DataAccess: MealplanManagementDataAccess + Send + Sync,
{
    resolver: RelationResolver<DataAccess>,
    parser: Parser,
}

impl<Parser, DataAccess> MealPlanManager<Parser, DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
    Parser: MealplanParser + Send + Sync,
{
    pub const fn _new(database: DataAccess, meal_plan_parser: Parser) -> Self {
        Self {
            resolver: RelationResolver { db: database },
            parser: meal_plan_parser,
        }
    }
}

#[async_trait]
impl<DataAccess, Parser> MensaParseScheduling for MealPlanManager<Parser, DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
    Parser: MealplanParser + Send + Sync,
{
    async fn start_update_parsing(&self) {
        let date = Utc::now().date_naive();

        for parse_canteen in self.parser.parse(date).await {
            let name = parse_canteen.name.clone();
            match self.resolver.resolve(parse_canteen, date).await {
                Ok(_canteen) => trace_canteen_resolved(&name),
                Err(e) => error_canteen_resolved(&name, &e)
            }
        }
    }

    async fn start_full_parsing(&self) {
        let parse_tuples = self.parser.parse_all().await;
        for (date, parse_canteens) in parse_tuples {
            for parse_canteen in parse_canteens {
                let name = parse_canteen.name.clone();
                match self.resolver.resolve(parse_canteen, date).await {
                    Ok(_canteen) => trace_canteen_resolved(&name),
                    Err(e) => error_canteen_resolved(&name, &e)
                }
            }
        }
    }
}

#[cfg(test)]
mod test {

    #[test]
    fn valid_start_update_parsing() {

    }

    #[test]
    #[should_panic]
    fn invalid_start_update_parsing() {

    }

    #[test]
    fn valid_start_full_parsing() {

    }

    #[test]
    #[should_panic]
    fn invalid_start_full_parsing() {

    }
}
