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
        
        assert!(self.shutdown.is_none(), "tried to start server twice");
        
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

    use async_graphql::{http::{playground_source, GraphQLPlaygroundConfig}, Json};
    use serial_test::serial;

    use crate::layer::trigger::graphql::{
        mock::{CommandMock, RequestDatabaseMock},
        server::GraphQLServer,
    };


    fn get_test_server() -> GraphQLServer {
        GraphQLServer::new(RequestDatabaseMock, CommandMock)
    }

    #[tokio::test]
    #[serial]
    /// Test whether api version is available as health check.
    async fn test_graphql() {
        let mut server = get_test_server();
        server.start();

        let test_request = r#"
        {
            "query": "{apiVersion}"
        }
        "#;

        let client = reqwest::Client::new();
        let resp = client
            .post("http://localhost:8090")
            .body(test_request)
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();

        assert_eq!("{\"data\":{\"apiVersion\":\"1.0\"}}", resp, "wrong data returned on graphql version health check.");


        server.shutdown().await;
    }

    #[tokio::test]
    #[serial]
    /// Test whether the graphql playground is served.
    async fn test_playground() {
        let mut server = get_test_server();
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
    /// test what happens when server is shutdown but not running.
    async fn test_not_running() {
        let mut server = get_test_server();

        server.shutdown().await;
    }


    /// Test what happens when server is started twice.
    #[tokio::test]
    #[should_panic = "tried to start server twice"]
    #[serial]
    async fn test_double_start() {
        let mut server = get_test_server();
        server.start();
        server.start();
    }
}
