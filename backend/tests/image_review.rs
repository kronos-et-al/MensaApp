use mensa_app_backend::{
    interface::image_review::ImageReviewScheduling,
    layer::{
        data::{
            database::factory::DataAccessFactory, flickr_api::flickr_api_handler::FlickrApiHandler,
        },
        logic::image_review::image_reviewer::ImageReviewer,
    },
    startup::config::ConfigReader,
};

#[tokio::test]
#[ignore = "manual test "]
async fn test_start_image_review() {
    let image_reviewer = setup().await;
    image_reviewer.start_image_review().await;
}

async fn setup() -> impl ImageReviewScheduling {
    let reader = ConfigReader::default();

    let image_hoster = FlickrApiHandler::new(reader.read_flickr_info().unwrap());

    let database_factory = DataAccessFactory::new(reader.read_database_info().unwrap(), false)
        .await
        .unwrap();
    let data_access = database_factory.get_image_review_data_access();
    ImageReviewer::new(data_access, image_hoster)
}
