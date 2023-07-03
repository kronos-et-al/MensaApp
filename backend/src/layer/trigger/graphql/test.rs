#![cfg(test)]
#![allow(clippy::unwrap_used)]

use async_graphql::http::{playground_source, GraphQLPlaygroundConfig};
use async_graphql::{EmptySubscription, Schema};
use serial_test::serial;

use crate::layer::trigger::graphql::mutation::MutationRoot;
use crate::layer::trigger::graphql::query::QueryRoot;

use super::mock::{CommandMock, RequestDatabaseMock};

use super::server::GraphQLServer;

#[tokio::test]
#[serial]
async fn test_graphql() {
    let mut server = GraphQLServer::new(RequestDatabaseMock, CommandMock);
    server.start();

    let client = reqwest::Client::new();
    let _resp = client
        .post("http://localhost:8090")
        .send()
        .await
        .unwrap()
        .text()
        .await
        .unwrap();

    // TODO this only checks whether a connection to the server could be made. A real check should be added later.
    server.shutdown().await;
}

#[tokio::test]
#[serial]
async fn test_playground() {
    let mut server = GraphQLServer::new(RequestDatabaseMock, CommandMock);
    server.start();

    let result = reqwest::get("http://localhost:8090")
        .await
        .unwrap()
        .text()
        .await
        .unwrap();
    let playground = playground_source(GraphQLPlaygroundConfig::new("/"));
    assert_eq!(playground, result);

    server.shutdown().await;
}

#[tokio::test]
async fn test_query() {
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(Box::new(RequestDatabaseMock))
        .data(Box::new(CommandMock))
        .finish();

    assert_eq!("", schema.execute("{test}").await.data.to_string());
}
