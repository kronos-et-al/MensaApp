//! This package contains the server that is responsible for providing the graphql API.

use std::fmt;

use async_graphql::{
    http::{playground_source, GraphQLPlaygroundConfig, GraphiQLSource},
    EmptySubscription, Schema,
};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    response::{self, IntoResponse},
    routing::get,
    Extension, Router, Server,
};

use crate::interface::{api_command::Command, persistent_data::RequestDataAccess};

use super::{mutation::MutationRoot, query::QueryRoot};
type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

/// Class witch controls the webserver for GraphQL requests.
pub struct GraphQLServer {
    schema: GraphQLSchema,
}

impl GraphQLServer {
    /// Creates a new Object with given access to datastore and logic for commands.
    pub fn new(
        data_access: impl RequestDataAccess + Sync + Send + 'static,
        command: impl Command + Sync + Send + 'static,
    ) -> Self {
        let schema: GraphQLSchema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
            .data(data_access)
            .data(command)
            .finish();

        Self { schema }
    }

    /// Starts the GraphQL-Server. It will be running in the background until [`Self::shutdown()`] is called.
    pub async fn start(&self) {
        let listen = "0.0.0.0:8080";

        let app = Router::new()
            .route("/", get(graphiql).post(graphql_handler))
            .layer(Extension(self.schema.clone()));

        Server::bind(
            &listen
                .parse()
                .expect("could not parse listening ip and port"),
        )
        .serve(app.into_make_service())
        .await
        .unwrap_or_else(|_| panic!("could not listen on {listen}"));
    }

    /// Stops the GraphQL server.
    pub fn shutdown(&self) {}
}

#[allow(clippy::unused_async)]
async fn graphiql() -> impl IntoResponse {
    response::Html(playground_source(GraphQLPlaygroundConfig::new("/")))
}

async fn graphql_handler(
    schema: Extension<GraphQLSchema>,
    request: GraphQLRequest,
) -> GraphQLResponse {
    schema.execute(request.into_inner()).await.into()
}
