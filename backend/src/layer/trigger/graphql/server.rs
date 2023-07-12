//! This package contains the server that is responsible for providing the graphql API.

use std::{
    fmt::Display,
    future::Future,
    mem,
    net::{Ipv6Addr, SocketAddrV6},
    pin::Pin,
    sync::Arc,
};

use async_graphql::{
    extensions::Tracing,
    http::{playground_source, GraphQLPlaygroundConfig},
    EmptySubscription, Schema,
};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    http::HeaderMap,
    response::{self, IntoResponse},
    routing::get,
    Extension, Router, Server,
};
use tokio::sync::Notify;
use tracing::info;

use crate::interface::{api_command::Command, persistent_data::RequestDataAccess};

use super::{
    mutation::MutationRoot,
    query::QueryRoot,
    util::{AuthHeader, CommandBox, DataBox},
};

type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub struct GraphQLServerInfo {
    pub port: u16,
}

enum State {
    Created,
    Running(Pin<Box<dyn Future<Output = ()> + Send>>),
    Finished,
}

impl Display for State {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let msg = match self {
            Self::Created => "created",
            Self::Running(_) => "running",
            Self::Finished => "finished",
        };
        write!(f, "{msg}")
    }
}

/// Class witch controls the webserver for GraphQL requests.
pub struct GraphQLServer {
    server_info: GraphQLServerInfo,
    schema: GraphQLSchema,
    state: State,
}

impl GraphQLServer {
    /// Creates a new Object with given access to datastore and logic for commands.
    pub fn new(
        server_info: GraphQLServerInfo,
        data_access: impl RequestDataAccess + Sync + Send + 'static,
        command: impl Command + Sync + Send + 'static,
    ) -> Self {
        let schema: GraphQLSchema = construct_schema(data_access, command);
        Self {
            server_info,
            schema,
            state: State::Created,
        }
    }

    /// Starts the GraphQL-Server. It will be running in the background until [`Self::shutdown()`] is called.
    ///
    /// # Panics
    /// This function panics if the server is in the wrong state, meaning it is already running or shut down.
    pub fn start(&mut self) {
        assert!(
            matches!(self.state, State::Created),
            "tried to start graphql server while in state {}",
            self.state
        );

        let app = Router::new()
            .route("/", get(graphql_playground).post(graphql_handler))
            .layer(Extension(self.schema.clone()));

        let socket = std::net::SocketAddr::V6(SocketAddrV6::new(
            Ipv6Addr::UNSPECIFIED,
            self.server_info.port,
            0,
            0,
        ));

        let server = Server::bind(&socket).serve(app.into_make_service());

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

        self.state = State::Running(Box::pin(shutdown));
        info!("Started graphql server listening on {}.", socket);
    }

    /// Stops the GraphQL server.
    ///
    /// # Panics
    /// - Panics if no server is in the wrong state, meaning it is not started or already shut down.
    /// - Panics if web server has panicked during execution or could not be finished.
    pub async fn shutdown(&mut self) {
        let shutdown = match mem::replace(&mut self.state, State::Finished) {
            State::Finished | State::Created => {
                panic!("tried to shutdown server but in state {}", self.state)
            }
            State::Running(s) => s,
        };

        shutdown.await;
        info!("Graphql server shutdown complete.");
    }
}

/// Constructs the graphql schema with all its settings.
pub(super) fn construct_schema(
    data_access: impl RequestDataAccess + Sync + Send + 'static,
    command: impl Command + Sync + Send + 'static,
) -> GraphQLSchema {
    let data_access_box: DataBox = Box::new(data_access);
    let command_box: CommandBox = Box::new(command);

    Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(data_access_box)
        .data(command_box)
        .extension(Tracing)
        .finish()
}

#[allow(clippy::unused_async)]
async fn graphql_playground() -> impl IntoResponse {
    response::Html(playground_source(GraphQLPlaygroundConfig::new("/")))
}

async fn graphql_handler(
    headers: HeaderMap,
    schema: Extension<GraphQLSchema>,
    request: GraphQLRequest,
) -> GraphQLResponse {
    let request = request.into_inner().data(
        headers
            .get("Authorization")
            .and_then(|h| h.to_str().ok())
            .unwrap_or("")
            .to_string() as AuthHeader,
    );
    schema.execute(request).await.into()
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

    use super::GraphQLServerInfo;

    const TEST_PORT: u16 = 12345;

    fn get_test_server() -> GraphQLServer {
        let info = GraphQLServerInfo { port: TEST_PORT };
        GraphQLServer::new(info, RequestDatabaseMock, CommandMock)
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
            .post(format!("http://localhost:{TEST_PORT}"))
            .body(test_request)
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();

        assert_eq!(
            "{\"data\":{\"apiVersion\":\"1.0\"}}", resp,
            "wrong data returned on graphql version health check."
        );

        server.shutdown().await;
    }

    #[tokio::test]
    #[serial]
    /// Test whether the graphql playground is served.
    async fn test_playground() {
        let mut server = get_test_server();
        server.start();

        let result = reqwest::get(format!("http://localhost:{TEST_PORT}"))
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
    #[should_panic = "tried to start graphql server while in state running"]
    #[serial]
    async fn test_double_start() {
        let mut server = get_test_server();
        server.start();
        server.start();
    }
}
