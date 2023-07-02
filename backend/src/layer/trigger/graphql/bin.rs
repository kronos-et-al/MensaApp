use mensa_app_backend::layer::trigger::graphql::*;



#[tokio::main]
async fn main() {
    let mut server = server::GraphQLServer::new(mock::RequestDatabaseMock, mock::CommandMock);
    server.start();
    tokio::signal::ctrl_c().await.expect("failed to listen for CTRL-C event");
    server.shutdown().await;
}