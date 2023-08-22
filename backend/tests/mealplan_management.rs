use mensa_app_backend::interface::mealplan_management::MensaParseScheduling;
use mensa_app_backend::layer::data::database::mealplan_management::PersistentMealplanManagementData;
use mensa_app_backend::layer::data::swka_parser::swka_parse_manager::SwKaParseManager;
use mensa_app_backend::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager;
use mensa_app_backend::{
    layer::data::database::factory::DataAccessFactory, startup::config::ConfigReader,
};

async fn setup() -> MealPlanManager<SwKaParseManager, PersistentMealplanManagementData> {
    let reader = ConfigReader::default();
    let mensa_parser = SwKaParseManager::new(reader.read_swka_info().unwrap()).unwrap();

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true)
        .await
        .unwrap();
    let data = factory.get_mealplan_management_data_access();
    MealPlanManager::new(data, mensa_parser)
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_start_full_parsing() {
    let mgmt = setup().await;
    mgmt.start_full_parsing().await;
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_start_update_parsing() {
    let mgmt = setup().await;
    mgmt.start_update_parsing().await;
}
