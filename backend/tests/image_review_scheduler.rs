use mensa_app_backend::{
    layer::{
        data::{
            database::factory::DataAccessFactory, flickr_api::flickr_api_handler::FlickrApiHandler,
            swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::{
            image_review::image_reviewer::ImageReviewer,
            mealplan_management::meal_plan_manager::MealPlanManager,
        },
        trigger::scheduling::scheduler::{ScheduleInfo, Scheduler},
    },
    startup::config::ConfigReader,
};

#[tokio::test]
async fn test_image_scheduling() {}

async fn setup() -> Scheduler {
    let info = ScheduleInfo {
        full_parse_schedule: "*/1 * * * * *".to_string(),
        update_parse_schedule: "*/2 * * * * *".to_string(),
        image_review_schedule: "*/5 * * * * *".to_string(),
    };
    let reader = ConfigReader::default();

    let image_hoster = FlickrApiHandler::new(reader.read_flickr_info().unwrap());
    let meal_plan_parser = SwKaParseManager::new(reader.read_swka_info().unwrap()).unwrap();
    let database_factory = DataAccessFactory::new(reader.read_database_info().unwrap(), false)
        .await
        .unwrap();
    let image_review_data = database_factory.get_image_review_data_access();
    let mealplan_management_data = database_factory.get_mealplan_management_data_access();

    let image_scheduling = ImageReviewer::new(image_review_data, image_hoster);

    let parse_scheduling = MealPlanManager::new(mealplan_management_data, meal_plan_parser);
    Scheduler::new(info, image_scheduling, parse_scheduling).await
}
