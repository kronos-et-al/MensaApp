use async_trait::async_trait;
use mensa_app_backend::{
    interface::image_review::ImageReviewScheduling,
    layer::{
        data::{
            database::factory::DataAccessFactory, swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::mealplan_management::meal_plan_manager::MealPlanManager,
        trigger::scheduling::scheduler::{ScheduleInfo, Scheduler},
    },
    startup::config::ConfigReader,
};
use tokio::signal::ctrl_c;

const NEVER: &str = "* * * 31 2 *";

#[tokio::test]
#[ignore = "manual test"]
async fn test_full_mensa_parse_scheduling() {
    let info = ScheduleInfo {
        full_parse_schedule: "0 */5 * * * *".to_string(),
        update_parse_schedule: NEVER.to_string(),
        image_review_schedule: NEVER.to_string(),
    };
    let mut scheduler = setup(info).await;
    scheduler.start().await;
    ctrl_c().await.unwrap();
    scheduler.shutdown().await;
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_update_mensa_parse_scheduling() {
    let info = ScheduleInfo {
        full_parse_schedule: NEVER.to_string(),
        update_parse_schedule: "0 */5 * * * *".to_string(),
        image_review_schedule: NEVER.to_string(),
    };
    let mut scheduler = setup(info).await;
    scheduler.start().await;
    ctrl_c().await.unwrap();
    scheduler.shutdown().await;
}

async fn setup(info: ScheduleInfo) -> Scheduler {
    let reader = ConfigReader::default();
    let database_factory = DataAccessFactory::new(reader.read_database_info().unwrap(), false)
        .await
        .unwrap();
    let mealplan_management_data = database_factory.get_mealplan_management_data_access();
    let parser = SwKaParseManager::new(reader.read_swka_info().unwrap()).unwrap();

    let mealplan_management = MealPlanManager::new(mealplan_management_data, parser);
    Scheduler::new(info, ImageSchedulingMock::default(), mealplan_management).await
}

#[derive(Default)]
struct ImageSchedulingMock {}

#[async_trait]
impl ImageReviewScheduling for ImageSchedulingMock {
    async fn start_image_review(&self) {
        return;
    }
}
