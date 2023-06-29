//! This package contains the server that is responsible for providing the graphql API.

use async_graphql::{http::GraphiQLSource, EmptySubscription, Schema};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    response::{self, IntoResponse},
    routing::get,
    Extension, Router, Server,
};

use crate::interface::{api_command::Command, persistent_data::RequestDataAccess};

use super::{mutation::MutationRoot, query::QueryRoot};

/// Class witch controls the webserver for GraphQL requests.
pub struct GraphQLServer {}

impl GraphQLServer {
    /// Creates a new Object with given access to datastore and logic for commands.
    pub fn new(data_access: impl RequestDataAccess, command: impl Command) -> Self {
        Self {}
    }

    /// Starts the GraphQL-Server. It will be running in the background until [`Self::shutdown()`] is called.
    pub async fn start(&self) {
        let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription).finish();

        let app = Router::new()
            .route("/", get(graphiql).post(graphql_handler))
            .layer(Extension(schema));

        Server::bind(&"0.0.0.0:8000".parse().unwrap())
            .serve(app.into_make_service())
            .await
            .unwrap();
    }

    /// Stops the GraphQL server.
    pub fn shutdown(&self) {}
}

type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

async fn graphiql() -> impl IntoResponse {
    response::Html(GraphiQLSource::build().endpoint("/").finish())
}

async fn graphql_handler(schema: Extension<GraphQLSchema>, request: GraphQLRequest) -> GraphQLResponse {
    schema.execute(request.into_inner()).await.into()
}
