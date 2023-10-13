use std::env::temp_dir;

use mensa_app_backend::layer::{
    logic::api_command::{
        command_handler::{CommandHandler, ImagePreprocessingInfo},
        mocks::{
            CommandAdminNotificationMock, CommandDatabaseMock, CommandImageStorageMock,
            CommandImageValidationMock,
        },
    },
    trigger::api::{mock::AuthDataMock, server::ApiServerInfo, *},
};
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[tokio::main]
async fn main() {
    // setup logging
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::TRACE)
        .pretty()
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    // run server
    let info = ApiServerInfo {
        port: 8090,
        image_dir: temp_dir(),
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
    );
    server.start();
    tokio::signal::ctrl_c()
        .await
        .expect("failed to listen for CTRL-C event");
    info!("stopping server...");
    server.shutdown().await;
}
