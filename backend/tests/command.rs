use mensa_app_backend::{
    interface::{
        api_command::{AuthInfo, Command, InnerAuthInfo},
        persistent_data::CommandDataAccess,
    },
    layer::{
        data::{
            database::factory::{DataAccessFactory, DatabaseInfo},
            flickr_api::flickr_api_handler::FlickrApiHandler,
            mail::mail_sender::MailSender,
        },
        logic::api_command::command_handler::CommandHandler,
    },
    startup::config::ConfigReader,
    util::Uuid,
};

#[tokio::test]
#[ignore = "manual test"]
async fn test_add_image() {
    let cmd = setup_cmd().await;

    let meal = Uuid::try_from("48b0ed7b-8387-46ad-866c-7993f469a9bf").unwrap();

    let auth_info = get_auth_info("T7X93M0t4oWRxRFxH2MpWdYSHZNsiqkkkpKbxL1AeD8wXR5pD+jmHvM4JjfD+WEx0Knl7g0DKSesmyzL2jVYxA==");

    cmd.add_image(meal, "https://flic.kr/p/2oSg8aV".into(), auth_info)
        .await
        .unwrap();
}

async fn setup_cmd() -> impl Command {
    let reader = ConfigReader::default();


    let mail = MailSender::new(reader.read_mail_info().unwrap()).unwrap();
    let hoster = FlickrApiHandler::new(reader.read_flickr_info().unwrap());

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true).await.unwrap();
    let data = factory.get_command_data_access();
    CommandHandler::new(data, mail, hoster).await.unwrap()
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
