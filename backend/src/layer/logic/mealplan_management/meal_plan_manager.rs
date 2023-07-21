use crate::interface::mealplan_management::MensaParseScheduling;
use crate::interface::mensa_parser::model::ParseCanteen;
use crate::interface::mensa_parser::MealplanParser;
use crate::interface::persistent_data::MealplanManagementDataAccess;
use crate::layer::logic::mealplan_management::relation_resolver::RelationResolver;
use crate::util::Date;
use async_trait::async_trait;
use chrono::Utc;
use tracing::log::{debug, warn};

pub struct MealPlanManager<Parser, DataAccess>
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
    pub const fn new(database: DataAccess, meal_plan_parser: Parser) -> Self {
        Self {
            resolver: RelationResolver::new(database),
            parser: meal_plan_parser,
        }
    }

    async fn start_resolving(&self, parse_canteens: Vec<ParseCanteen>, date: Date) {
        for parse_canteen in parse_canteens {
            let name = &parse_canteen.name.clone();
            match self.resolver.resolve(parse_canteen, date).await {
                Ok(()) => debug!("resolved canteen '{name}' with no errors"),
                Err(error) => warn!("resolved canteen '{name}' with errors: {error}"),
            }
        }
    }
}

#[async_trait]
impl<DataAccess, Parser> MensaParseScheduling for MealPlanManager<Parser, DataAccess>
where
    DataAccess: MealplanManagementDataAccess,
    Parser: MealplanParser,
{
    /// This method starts the parsing procedure for all meal plans **of the current day**.<br>
    /// After parsing, the raw data objects (`Vec<ParseCanteen>`) will be inserted by the [`RelationResolver`] with the current day.<br>
    /// If during resolving an error occurs, the resolver stops and a log will be displayed.<br>
    /// Each successful resolving process is also logged.
    async fn start_update_parsing(&self) {
        let today = Utc::now().date_naive();
        match self.parser.parse(today).await {
            Ok(parse_canteens) => {
                self.start_resolving(parse_canteens, today).await;
            }
            Err(error) => {
                warn!("canteens parsed with error and can't be resolved: {error}");
            }
        }
    }

    /// Similar to `start_update_parsing` this method starts the parsing procedure for all meal plans **for the next four weeks**.<br>
    /// After parsing, the raw data objects (`Vec<(Date, Vec<ParseCanteen>>`) will be inserted by the [`RelationResolver`].<br>
    /// If during resolving an error occurs, the resolver stops and a log will be displayed.<br>
    /// Each successful resolving process is also logged.
    async fn start_full_parsing(&self) {
        match self.parser.parse_all().await {
            Ok(parse_tuples) => {
                for (date, parse_canteens) in parse_tuples {
                    self.start_resolving(parse_canteens, date).await;
                }
            }
            Err(error) => {
                warn!("canteens parsed with error and can't be resolved: {error}");
            }
        }
    }
}

#[cfg(test)]
mod test {
    use crate::interface::mealplan_management::MensaParseScheduling;
    use crate::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager;
    use crate::layer::logic::mealplan_management::test::meal_plan_parser_mock::MealPlanParserMock;
    use crate::layer::logic::mealplan_management::test::mealplan_management_database_mock::MealplanManagementDatabaseMock;

    #[tokio::test]
    async fn valid_start_update_parsing() {
        gen_random_uuid();
        let manager = MealPlanManager::new(MealplanManagementDatabaseMock, MealPlanParserMock);
        manager.start_update_parsing().await;
    }

    #[tokio::test]
    async fn valid_start_full_parsing() {
        let manager = MealPlanManager::new(MealplanManagementDatabaseMock, MealPlanParserMock);
        manager.start_full_parsing().await;
    }
}
