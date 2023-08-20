use async_trait::async_trait;
use mensa_app_backend::{
    interface::mealplan_management::MensaParseScheduling,
    layer::{
        data::{
            database::factory::DataAccessFactory, flickr_api::flickr_api_handler::FlickrApiHandler,
        },
        logic::image_review::image_reviewer::ImageReviewer,
        trigger::scheduling::scheduler::{ScheduleInfo, Scheduler},
    },
    startup::config::ConfigReader,
};
use tokio::signal::ctrl_c;

#[tokio::test]
async fn test_image_scheduling() {
    let mut scheduler = setup().await;
    scheduler.start().await;
    ctrl_c().await.unwrap();
    scheduler.shutdown().await;
}

async fn setup() -> Scheduler {
    let info = ScheduleInfo {
        full_parse_schedule: "* * * * * 0".to_string(),
        update_parse_schedule: "* * * * * 0".to_string(),
        image_review_schedule: "*/5 * * * * *".to_string(),
    };
    let reader = ConfigReader::default();
    let database_factory = DataAccessFactory::new(reader.read_database_info().unwrap(), false)
        .await
        .unwrap();
    let image_review_data = database_factory.get_image_review_data_access();
    let image_hoster = FlickrApiHandler::new(reader.read_flickr_info().unwrap());
    let image_scheduling = ImageReviewer::new(image_review_data, image_hoster);
    Scheduler::new(info, image_scheduling, MealplanManagerMock::default()).await
}

#[derive(Default)]
struct MealplanManagerMock {}

#[async_trait]
impl MensaParseScheduling for MealplanManagerMock {
    async fn start_update_parsing(&self) {
        return;
    }

    async fn start_full_parsing(&self) {
        return;
    }
}
