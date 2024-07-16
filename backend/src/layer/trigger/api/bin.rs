use std::env::temp_dir;

use dotenvy::dotenv;
use mensa_app_backend::layer::{
    logic::api_command::{
        command_handler::CommandHandler,
        image_preprocessing::ImagePreprocessingInfo,
        mocks::{
            CommandAdminNotificationMock, CommandDatabaseMock, CommandImageStorageMock,
            CommandImageValidationMock,
        },
    },
    trigger::api::{mock::AuthDataMock, server::ApiServerInfo, *},
};
use tracing::info;
use tracing_subscriber::{EnvFilter, FmtSubscriber};

#[tokio::main]
async fn main() {
    dotenv().ok();
    // setup logging
    let subscriber = FmtSubscriber::builder()
        .with_env_filter(
            EnvFilter::builder()
                .with_env_var("LOG_CONFIG")
                .from_env_lossy(),
        )
        .pretty()
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    // run server
    let info = ApiServerInfo {
        port: 8090,
        image_dir: temp_dir(),
        rate_limit: None,
        max_body_size: 10 << 20,
        admin_key: "admin".into(),
    };

    let image_pre_info = ImagePreprocessingInfo {
        max_image_height: 1080,
        max_image_width: 1920,
    };

    let mut server = server::ApiServer::new(
        info,
        mock::RequestDatabaseMock,
        CommandHandler::new(
            image_pre_info,
            CommandDatabaseMock,
            CommandAdminNotificationMock,
            CommandImageStorageMock,
            CommandImageValidationMock,
        )
        .expect("could not create command mock"),
        AuthDataMock,
    )
    .await;
    server.start();
    tokio::signal::ctrl_c()
        .await
        .expect("failed to listen for CTRL-C event");
    info!("stopping server...");
    server.shutdown().await;
}
