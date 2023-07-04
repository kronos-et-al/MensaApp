//! This package contains the server that is responsible for providing the graphql API.

use std::{future::Future, pin::Pin, sync::Arc};

use async_graphql::{
    extensions::Tracing,
    http::{playground_source, GraphQLPlaygroundConfig},
    EmptySubscription, Schema,
};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    response::{self, IntoResponse},
    routing::get,
    Extension, Router, Server,
};
use tokio::sync::Notify;

use crate::interface::{api_command::Command, persistent_data::RequestDataAccess};

use super::{
    mutation::MutationRoot,
    query::QueryRoot,
    util::{CommandBox, DataBox},
};
type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

/// Class witch controls the webserver for GraphQL requests.
pub struct GraphQLServer {
    schema: GraphQLSchema,
    shutdown: Option<Pin<Box<dyn Future<Output = ()> + Send>>>,
}

impl GraphQLServer {
    /// Creates a new Object with given access to datastore and logic for commands.
    pub fn new(
        data_access: impl RequestDataAccess + Sync + Send + 'static,
        command: impl Command + Sync + Send + 'static,
    ) -> Self {
        let data_access_box: DataBox = Box::new(data_access);
        let command_box: CommandBox = Box::new(command);

        let schema: GraphQLSchema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
            .data(data_access_box)
            .data(command_box)
            .extension(Tracing)
            .finish();

        Self {
            schema,
            shutdown: None,
        }
    }

    /// Starts the GraphQL-Server. It will be running in the background until [`Self::shutdown()`] is called.
    pub fn start(&mut self) {
        let listen = "0.0.0.0:8090"; // TODO Ipv6?

        let app = Router::new()
            .route("/", get(graphql_playground).post(graphql_handler))
            .layer(Extension(self.schema.clone()));

        let server = Server::bind(
            &listen
                .parse()
                .expect("could not parse listening ip and port"), // TODO proper error handling
        )
        .serve(app.into_make_service());

        let shutdown_notify = Arc::new(Notify::new());
        let shutdown_notify_sender = shutdown_notify.clone();

        let with_shutdown =
            server.with_graceful_shutdown(async move { shutdown_notify_sender.notified().await });

        let join_handle = tokio::spawn(with_shutdown);

        let shutdown = async move {
            shutdown_notify.notify_waiters();
            join_handle
                .await
                .expect("web server should not have panicked")
                .expect("error while waiting for webserver to finish");
        };

        self.shutdown = Some(Box::pin(shutdown));
    }

    /// Stops the GraphQL server.
    pub async fn shutdown(&mut self) {
        self.shutdown
            .take()
            .expect("trying to shutdown server but not running")
            .await;
    }
}

#[allow(clippy::unused_async)]
async fn graphql_playground() -> impl IntoResponse {
    response::Html(playground_source(GraphQLPlaygroundConfig::new("/")))
}

async fn graphql_handler(
    schema: Extension<GraphQLSchema>,
    request: GraphQLRequest,
) -> GraphQLResponse {
    schema.execute(request.into_inner()).await.into()
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use async_graphql::http::{playground_source, GraphQLPlaygroundConfig};
    use serial_test::serial;

    use crate::layer::trigger::graphql::{
        mock::{CommandMock, RequestDatabaseMock},
        server::GraphQLServer,
    };

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
    #[should_panic]
    async fn test_not_running() {
        let mut server = GraphQLServer::new(RequestDatabaseMock, CommandMock);

        server.shutdown().await;
    }
}