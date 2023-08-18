use mensa_app_backend::{
    layer::{
        data::{
            database::factory::DataAccessFactory,
        },
    },
    startup::config::ConfigReader,
};
use mensa_app_backend::layer::data::database::mealplan_management::PersistentMealplanManagementData;
use mensa_app_backend::layer::data::swka_parser::swka_parse_manager::SwKaParseManager;
use mensa_app_backend::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager;

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image() {
    let cmd = setup_cmd().await;

    start_full_with_empty_db();

    start_update_with_empty_db();

    start_full_with_filled_db();

    start_update_with_filled_db();
}

async fn setup_cmd() -> MealPlanManager<SwKaParseManager, PersistentMealplanManagementData> {
    let reader = ConfigReader::default();
    let mensa_parser = SwKaParseManager::new(reader.read_swka_info().unwrap())?
        .unwrap();

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true).await.unwrap();
    let data = factory.get_mealplan_management_data_access();
    MealPlanManager::new(data, mensa_parser)
}


fn start_full_with_empty_db() {

}

fn start_update_with_empty_db() {

}

fn start_full_with_filled_db() {

}

fn start_update_with_filled_db() {

}