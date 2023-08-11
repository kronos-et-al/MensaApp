use futures::Future;
use mensa_app_backend::{
    interface::{
        api_command::{AuthInfo, Command, InnerAuthInfo},
        persistent_data::{CommandDataAccess, MealplanManagementDataAccess},
    },
    layer::{
        data::{
            database::{command::PersistentCommandData, factory::DataAccessFactory},
            flickr_api::flickr_api_handler::FlickrApiHandler,
            mail::{mail_info::MailInfo, mail_sender::MailSender},
        },
        logic::api_command::command_handler::CommandHandler,
    },
    startup::config::ConfigReader,
    util::{MealType, Uuid},
};
use sqlx::{
    migrate::{MigrateDatabase, Migration},
    Database, PgPool,
};

#[tokio::test]
#[ignore = "manual test"]
async fn test_command() {
    use_database("name", |cmd, factory, pool| async move {
        let insertion = factory.get_mealplan_management_data_access();
        // let canteen = insertion.insert_canteen("canteen", 0).await.unwrap();
        // let line = insertion.insert_line(canteen, "line", 0).await.unwrap();
        let meal1 = insertion
            .insert_meal("meal1", MealType::Beef, &[], &[])
            .await
            .unwrap();

        let client_id = Uuid::new_v4();
        let auth_info = Some(InnerAuthInfo {
            api_ident: API_KEY.into(),
            client_id,
            hash: "".into(),
        });

        cmd.add_image(meal1, "image_url".into(), auth_info)
            .await
            .unwrap();
    })
    .await;
}

const API_KEY: &str = "abcdefghij";

async fn use_database<T: Future<Output = ()>>(
    name: &str,
    action: impl (FnOnce(
        CommandHandler<PersistentCommandData, MailSender, FlickrApiHandler>,
        DataAccessFactory,
        PgPool,
    ) -> T),
) {
    let reader = ConfigReader::default();
    let mut info = reader.read_database_info().unwrap();
    info.connection += "_command_test_";
    info.connection += name;
    let conn = info.connection.clone();

    {
        // setup database
        if sqlx::Postgres::database_exists(&conn).await.unwrap() {
            sqlx::Postgres::drop_database(&conn).await.unwrap();
        }
        sqlx::Postgres::create_database(&conn).await.unwrap();

        let pool = PgPool::connect_lazy(&conn).unwrap();
        sqlx::query!(
            "INSERT INTO api_key(api_key, description) VALUES ($1, 'default')",
            API_KEY
        )
        .execute(&pool)
        .await
        .unwrap();
        // setup cmd

        let mail = MailSender::new(reader.read_mail_info().unwrap()).unwrap();
        let hoster = FlickrApiHandler::new(reader.read_flickr_info().unwrap());

        let factory = DataAccessFactory::new(info, true).await.unwrap();
        let data = factory.get_command_data_access();
        let cmd = CommandHandler::new(data, mail, hoster).await.unwrap();

        action(cmd, factory, pool).await;
    }

    // delete database out of scope
    sqlx::Postgres::drop_database(&conn).await.unwrap();
}
