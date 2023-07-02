#![cfg(test)]

use tokio::time::Duration;

use super::mock::{CommandMock, RequestDatabaseMock};

use super::server::GraphQLServer;

#[tokio::test]
async fn run_server() {
    let mut server = GraphQLServer::new(RequestDatabaseMock, CommandMock);
    server.start();
    tokio::time::sleep(Duration::from_secs(10)).await;
    server.shutdown().await;
}
