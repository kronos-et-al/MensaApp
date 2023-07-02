#![cfg(test)]

use async_trait::async_trait;
use tokio::time::Duration;
use uuid::Uuid;

use super::mock::*;

use super::server::GraphQLServer;

#[tokio::test]
async fn run_server() {
    let mut server = GraphQLServer::new(RequestDatabaseMock, CommandMock);
    server.start();
    tokio::time::sleep(Duration::from_secs(10)).await;
    server.shutdown().await;
}
