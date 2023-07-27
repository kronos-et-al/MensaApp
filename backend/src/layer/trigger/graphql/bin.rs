use mensa_app_backend::layer::{
    logic::api_command::{
        command_handler::CommandHandler,
        test::mocks::{CommandAdminNotificationMock, CommandDatabaseMock, CommandImageHosterMock},
    },
    trigger::graphql::{server::GraphQLServerInfo, *},
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
    let info = GraphQLServerInfo { port: 8090 };

    let mut server = server::GraphQLServer::new(
        info,
        mock::RequestDatabaseMock,
        CommandHandler::new(
            CommandDatabaseMock,
            CommandAdminNotificationMock,
            CommandImageHosterMock,
        )
        .await
        .expect("could not create command mock"),
    );
    server.start();
    tokio::signal::ctrl_c()
        .await
        .expect("failed to listen for CTRL-C event");
    info!("stopping server...");
    server.shutdown().await;
}
