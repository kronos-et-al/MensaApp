use lazy_static::lazy_static;
use mensa_app_backend::{
    interface::api_command::{AuthInfo, Command, InnerAuthInfo},
    layer::{
        data::{database::factory::DataAccessFactory, mail::mail_sender::MailSender},
        logic::api_command::{
            command_handler::CommandHandler,
            mocks::{CommandFileHandlerMock, CommandImageValidationMock},
        },
    },
    startup::config::ConfigReader,
    util::{ReportReason, Uuid},
};

lazy_static! {
    static ref MEAL_ID: Uuid = Uuid::try_from("48b0ed7b-8387-46ad-866c-7993f469a9bf").unwrap();
    static ref IMAGE_ID: Uuid = Uuid::try_from("1b8f373b-7383-4a3a-9818-e0137fd164b7").unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image() {
    let cmd = setup_cmd().await;

    let auth_info = get_auth_info(
        "T7X93M0t4oWRxRFxH2MpWdYSHZNsiqkkkpKbxL1AeD8wXR5pD+jmHvM4JjfD+WEx0Knl7g0DKSesmyzL2jVYxA==",
    );

    cmd.add_image(*MEAL_ID, "https://flic.kr/p/2oSg8aV".into(), auth_info)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_report_image() {
    let cmd = setup_cmd().await;

    let reason = ReportReason::NoMeal;

    let auth_info = get_auth_info(
        "rxGJ5jz4aMwklyzFxZq6eHlySLuuPyv2+ixnzz8hDB2UQ+KuiJOaLKtINJh/iPZmgAEipA7E/ADceiFSO1RWmQ==",
    );

    cmd.report_image(*IMAGE_ID, reason, auth_info)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_set_meal_rating() {
    let cmd = setup_cmd().await;

    let rating = 4;

    let auth_info = get_auth_info(
        "YXBIcDFORrhY83pBmwuSwb0l0zsYXM/h18OfT+AMEYCXWCtpExlN2EMiLtjGkv7w2/cAPmIKe8m+mQbGasbcEQ==",
    );

    cmd.set_meal_rating(*MEAL_ID, rating, auth_info)
        .await
        .unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image_upvote() {
    let cmd = setup_cmd().await;

    let auth_info = get_auth_info(
        "r+tenhKxOfa2wJUE+EPzOyRgtIc5IBDjh/iMyvlP4vznoiLLsJKOMyKOs60ZV98oPrOEMpyDnONdavwFgnoH+g==",
    );

    cmd.add_image_upvote(*IMAGE_ID, auth_info).await.unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image_dovnvote() {
    let cmd = setup_cmd().await;

    let auth_info = get_auth_info(
        "aKlyzgxz/0pHK+LWQFHhWoyhUjOKa+/fmr6my4VH3Rxn+lPvvXb4lk3rENx8TSwCd2Sjw7qspPrs2S93ZoG/fQ==",
    );

    cmd.add_image_downvote(*IMAGE_ID, auth_info).await.unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_remove_image_upvote() {
    let cmd = setup_cmd().await;

    let auth_info = get_auth_info(
        "aNN/2nk2JgE0wZOMWG0zzxg/LtqaCeiLhjq7ebqDrnSSXtWVJC9kItKk1/RBKnzD+T+gGH/JGclBy8SWdgBKMQ==",
    );

    cmd.remove_image_upvote(*IMAGE_ID, auth_info).await.unwrap();
}

#[tokio::test]
#[ignore = "manual test"]
async fn test_remove_image_downvote() {
    let cmd = setup_cmd().await;

    let auth_info = get_auth_info(
        "65KlFbT+MijU8OqUWOleQZ/oxikIGp7q4hbEYTlEMnjbylrzNnl8nZUa1LEFaKZptAW46PmGJ/Xgcm6p4FzQxg==",
    );

    cmd.remove_image_downvote(*IMAGE_ID, auth_info)
        .await
        .unwrap();
}

// todo redo / remove test?
async fn setup_cmd() -> impl Command {
    let reader = ConfigReader::default();

    let mail = MailSender::new(reader.read_mail_info().unwrap()).unwrap();
    let file_handler = CommandFileHandlerMock; // todo
    let image_validation = CommandImageValidationMock; // todo

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true)
        .await
        .unwrap();
    let data = factory.get_command_data_access();
    CommandHandler::new(data, mail, file_handler, image_validation)
        .await
        .unwrap()
}

fn get_auth_info(hash: &str) -> AuthInfo {
    let client_id = Uuid::try_from("6f04a6c7-9723-4a01-ae8c-67baa62fba75").unwrap();
    const API_IDENT: &str = "1234567890";

    Some(InnerAuthInfo {
        api_ident: API_IDENT.into(),
        client_id,
        hash: hash.into(),
    })
}
