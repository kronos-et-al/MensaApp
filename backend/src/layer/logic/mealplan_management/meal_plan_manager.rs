use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::{MealplanManagementDataAccess};
use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
use async_trait::async_trait;
use chrono::{Utc};
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::layer::logic::mealplan_management::util::{error_canteen_resolved, trace_canteen_resolved};
use crate::util::Date;

pub struct MealPlanManager<Parser, DataAccess>
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
    pub fn new(database: DataAccess, meal_plan_parser: Parser) -> Self {
        Self {
            resolver: RelationResolver::new(database),
            parser: meal_plan_parser,
        }
    }

    async fn start_resolving(&self, parse_canteens: Vec<ParseCanteen>, date: Date) {
        for parse_canteen in parse_canteens {
            let name = parse_canteen.name.clone();
            match self.resolver.resolve(parse_canteen, date).await {
                Ok(_canteen) => trace_canteen_resolved(&name),
                Err(e) => error_canteen_resolved(&name, &e)
            }
        }
    }
}

#[async_trait]
impl<DataAccess, Parser> MensaParseScheduling for MealPlanManager<Parser, DataAccess>
where
    DataAccess: MealplanManagementDataAccess + Send + Sync,
    Parser: MealplanParser + Send + Sync,
{
    //TODO transactions if relation_resolve fails and we dont want uncompleted meal plans?
    /// This method starts the parsing procedure for all meal plans **of the current day**.<br>
    /// After parsing, the raw data objects (`Vec<ParseCanteen>`) will be inserted by the `RelationResolver` with the current day.<br>
    /// If during resolving an error occurs, the resolver stops and a log will be displayed.<br>
    /// Each successful resolving process is also logged.
    async fn start_update_parsing(&self) {
        let today = Utc::now().date_naive();
        self.start_resolving(self.parser.parse(today).await, today);
    }

    /// Similar to `start_update_parsing` this method starts the parsing procedure for all meal plans **for the next four weeks**.<br>
    /// After parsing, the raw data objects (`Vec<(Date, Vec<ParseCanteen>>`) will be inserted by the `RelationResolver`.<br>
    /// If during resolving an error occurs, the resolver stops and a log will be displayed.<br>
    /// Each successful resolving process is also logged.
    async fn start_full_parsing(&self) {
        let parse_tuples = self.parser.parse_all().await;
        for (date, parse_canteens) in parse_tuples {
            self.start_resolving(parse_canteens, date);
        }
    }
}

#[cfg(test)]
mod test {

    #[test]
    fn valid_start_update_parsing() {
        todo!()
    }

    #[test]
    #[should_panic]
    fn invalid_start_update_parsing() {
        todo!()
    }

    #[test]
    fn valid_start_full_parsing() {
        todo!()
    }

    #[test]
    #[should_panic]
    fn invalid_start_full_parsing() {
        todo!()
    }
}
