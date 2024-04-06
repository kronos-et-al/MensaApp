use lazy_static::lazy_static;
use mensa_app_backend::{
    interface::api_command::Command,
    layer::{
        data::{
            database::factory::DataAccessFactory, file_handler::FileHandler,
            mail::mail_sender::MailSender,
        },
        logic::api_command::{command_handler::CommandHandler, mocks::CommandImageValidationMock},
    },
    startup::config::ConfigReader,
    util::{ReportReason, Uuid},
};

lazy_static! {
    static ref MEAL_ID: Uuid = Uuid::try_from("48b0ed7b-8387-46ad-866c-7993f469a9bf").unwrap();
    static ref IMAGE_ID: Uuid = Uuid::try_from("1b8f373b-7383-4a3a-9818-e0137fd164b7").unwrap();
    static ref CLIENT_ID: Uuid = Uuid::try_from("6f04a6c7-9723-4a01-ae8c-67baa62fba75").unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image() {
    let cmd = setup_cmd().await;
    let image = include_bytes!("test.jpg").to_vec();

    cmd.add_image(*MEAL_ID, Some("image/jpeg".into()), image, *CLIENT_ID)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_report_image() {
    let cmd = setup_cmd().await;

    let reason = ReportReason::NoMeal;

    cmd.report_image(*IMAGE_ID, reason, *CLIENT_ID)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_set_meal_rating() {
    let cmd = setup_cmd().await;

    let rating = 4;

    cmd.set_meal_rating(*MEAL_ID, rating, *CLIENT_ID)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image_upvote() {
    let cmd = setup_cmd().await;

    cmd.add_image_upvote(*IMAGE_ID, *CLIENT_ID).await.unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image_dovnvote() {
    let cmd = setup_cmd().await;

    cmd.add_image_downvote(*IMAGE_ID, *CLIENT_ID).await.unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_remove_image_upvote() {
    let cmd = setup_cmd().await;

    cmd.remove_image_upvote(*IMAGE_ID, *CLIENT_ID)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_remove_image_downvote() {
    let cmd = setup_cmd().await;

    cmd.remove_image_downvote(*IMAGE_ID, *CLIENT_ID)
        .await
        .unwrap();
}

// todo redo / remove test?
async fn setup_cmd() -> impl Command {
    let reader = ConfigReader::default();

    let mail = MailSender::new(reader.read_mail_info().unwrap()).unwrap();
    let file_handler = FileHandler::new(reader.read_file_handler_info().await.unwrap());
    let image_validation = CommandImageValidationMock; // todo

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true)
        .await
        .unwrap();
    let data = factory.get_command_data_access();
    CommandHandler::new(
        reader.read_image_preprocessing_info(),
        data,
        mail,
        file_handler,
        image_validation,
    )
    .unwrap()
}
