//! This package contains the server that is responsible for providing the graphql and image API.

use std::{
    fmt::Display,
    future::Future,
    mem,
    net::{Ipv6Addr, SocketAddrV6},
    num::NonZeroU64,
    path::PathBuf,
    pin::Pin,
    sync::Arc,
    time::Duration,
};

use async_graphql::{
    extensions::Tracing,
    http::{playground_source, GraphQLPlaygroundConfig},
    EmptySubscription, Schema,
};
use async_graphql_axum::{GraphQLRequest, GraphQLResponse};
use axum::{
    error_handling::HandleErrorLayer,
    extract::DefaultBodyLimit,
    handler::Handler,
    middleware,
    response::{self, IntoResponse},
    routing::get,
    BoxError, Extension, Router, Server,
};

use hyper::StatusCode;
use tokio::sync::Notify;
use tower::{buffer::BufferLayer, limit::RateLimitLayer, ServiceBuilder};
use tower_http::services::ServeDir;
use tracing::{debug, info, info_span, Instrument};

use crate::{
    interface::{
        api_command::Command,
        persistent_data::{model::ApiKey, AuthDataAccess, RequestDataAccess},
    },
    layer::trigger::api::auth::auth_middleware,
    util::{local_to_global_url, IMAGE_BASE_PATH},
};

use super::{
    auth::AuthInfo,
    mutation::MutationRoot,
    query::QueryRoot,
    util::{CommandBox, DataBox},
};

type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

/// Information necessary to create a [`ApiServerInfo`].
pub struct ApiServerInfo {
    /// Port under which the server should run.
    pub port: u16,
    /// Directory where images are stored.
    pub image_dir: PathBuf,
    /// Max number of requests per second, `None` means disabled.
    pub rate_limit: Option<NonZeroU64>,
    /// Maximum accepted http body size
    pub max_body_size: u64,
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

/// Class witch controls the webserver for API requests.
pub struct ApiServer {
    server_info: ApiServerInfo,
    schema: GraphQLSchema,
    state: State,
    api_keys: Vec<ApiKey>,
}

impl ApiServer {
    /// Creates a new Object with given access to datastore and logic for commands.
    /// # Panics
    /// if api keys could not be read from database
    pub async fn new(
        server_info: ApiServerInfo,
        data_access: impl RequestDataAccess + 'static,
        command: impl Command + 'static,
        auth: impl AuthDataAccess,
    ) -> Self {
        let schema: GraphQLSchema = construct_schema(data_access, command);
        Self {
            server_info,
            schema,
            state: State::Created,
            api_keys: auth
                .get_api_keys()
                .await
                .expect("could not get api keys from database"),
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

        let auth = middleware::from_fn_with_state(self.api_keys.clone(), auth_middleware);

        let rate_limit = ServiceBuilder::new()
            .layer(HandleErrorLayer::new(|err: BoxError| async move {
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    format!("Unhandled error: {err}"),
                )
            }))
            .layer(BufferLayer::new(1024))
            .layer(RateLimitLayer::new(
                self.server_info
                    .rate_limit
                    .map_or(u64::MAX, NonZeroU64::get), // disable if none
                Duration::from_secs(1),
            ));

        let app = Router::new()
            .route(
                "/",
                get(graphql_playground).post(graphql_handler.layer(auth)),
            )
            .layer(Extension(self.schema.clone()))
            .nest_service(IMAGE_BASE_PATH, ServeDir::new(&self.server_info.image_dir))
            .layer(rate_limit)
            .layer(DefaultBodyLimit::max(
                self.server_info
                    .max_body_size
                    .try_into()
                    .expect("max body size should fit in usize"),
            ));

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
            shutdown_notify.notify_one();
            join_handle
                .await
                .expect("web server should not have panicked")
                .expect("error while waiting for webserver to finish");
        };

        self.state = State::Running(Box::pin(shutdown));
        info!("Started graphql server listening on http://{}.", socket);
        info!("Api publicly accessible under: {}", local_to_global_url(""));
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

#[axum::debug_handler]
async fn graphql_handler(
    Extension(auth_info): Extension<AuthInfo>,
    Extension(schema): Extension<GraphQLSchema>,
    request: GraphQLRequest,
) -> GraphQLResponse {
    let request = request.into_inner().data(auth_info.clone() as AuthInfo);

    let span = info_span!(
        "incoming graphql request",
        variables = %request.variables,
        auth_info = %auth_info
    );

    async {
        let response = schema.execute(request).await;
        if response.is_err() {
            debug!(errors = ?response.errors, "Error handling request");
        }
        response.into()
    }
    .instrument(span)
    .await
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use std::{env::temp_dir, io::Cursor, path::PathBuf};

    use async_graphql::http::{playground_source, GraphQLPlaygroundConfig};
    use image::{io::Reader, DynamicImage, ImageBuffer, ImageFormat};
    use reqwest::header::{AUTHORIZATION, CONTENT_TYPE};
    use serial_test::serial;

    use crate::{
        layer::trigger::api::{
            mock::{AuthDataMock, CommandMock, RequestDatabaseMock},
            server::ApiServer,
        },
        util::ImageResource,
    };

    use super::{ApiServerInfo, IMAGE_BASE_PATH};

    const TEST_PORT: u16 = 12345;
    const BODY_SIZE: u64 = 10 << 20;

    async fn get_test_server() -> ApiServer {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir: temp_dir(),
            rate_limit: None,
            max_body_size: BODY_SIZE,
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock).await
    }

    async fn get_test_server_with_images(image_dir: PathBuf) -> ApiServer {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir,
            rate_limit: None,
            max_body_size: BODY_SIZE,
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock).await
    }

    #[tokio::test]
    #[serial]
    /// Test whether api version is available as health check.
    async fn test_graphql() {
        let mut server = get_test_server().await;
        server.start();

        let test_request = r#"
        {
            "query": "{apiVersion}"
        }
        "#;

        let client = reqwest::Client::new();
        let resp = client
            .post(format!("http://localhost:{TEST_PORT}"))
            .header(
                AUTHORIZATION,
                "Mensa MWQ3NWQzODAtY2YwNy00ZWRiLTkwNDYtYTJkOTgxYmMyMTlkOmFiYzoxMjM=",
            )
            .body(test_request)
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();

        assert_eq!(
            format!(
                "{{\"data\":{{\"apiVersion\":\"{}\"}}}}",
                env!("CARGO_PKG_VERSION")
            ),
            resp,
            "wrong data returned on graphql version health check."
        );

        server.shutdown().await;
    }

    #[tokio::test]
    #[serial]
    /// Test whether the graphql playground is served.
    async fn test_playground() {
        let mut server = get_test_server().await;
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
        let mut server = get_test_server().await;

        server.shutdown().await;
    }

    /// Test what happens when server is started twice.
    #[tokio::test]
    #[should_panic = "tried to start graphql server while in state running"]
    #[serial]
    async fn test_double_start() {
        let mut server = get_test_server().await;
        server.start();
        server.start();
    }

    #[tokio::test]
    #[serial]
    async fn test_images() {
        let image_folder =
            tempfile::TempDir::new().expect("should be able to create temporary folder");

        let image =
            ImageResource::ImageRgb8(ImageBuffer::from_fn(10, 10, |_, _| image::Rgb([10u8; 3])));

        let image_name = "test.jpg";
        let mut image_path = image_folder.path().to_path_buf();
        image_path.push(image_name);

        let image_name_2 = "foo.png";
        let mut image_path_2 = image_folder.path().to_path_buf();
        image_path_2.push(image_name_2);

        image
            .save(image_path)
            .expect("should be able to save image");

        println!(
            "Files in image dir: {:?}",
            image_folder
                .path()
                .read_dir()
                .unwrap()
                .map(Result::unwrap)
                .collect::<Vec<_>>()
        );

        let mut server = get_test_server_with_images(image_folder.path().to_owned()).await;
        server.start();

        // save image after server is started to check "dynamic" file requests
        image
            .save(image_path_2)
            .expect("should be able to save image");

        // performing request

        let resp_image_1 = request_image(image_name).await;
        let resp_image_2 = request_image(image_name_2).await;
        assert_eq!(image, resp_image_1); // only works if image is simple (e.g. monotone) due to compression
        assert_eq!(image, resp_image_2);

        // ----
        server.shutdown().await;
    }

    async fn request_image(image_name: &str) -> DynamicImage {
        let resp = reqwest::get(format!(
            "http://localhost:{TEST_PORT}{IMAGE_BASE_PATH}/{image_name}"
        ))
        .await
        .unwrap();

        let file_type = resp.headers()[CONTENT_TYPE].to_str().unwrap().to_owned();
        let resp_bytes = resp.bytes().await.unwrap();
        let mut reader = Reader::new(Cursor::new(&resp_bytes));
        reader.set_format(ImageFormat::from_mime_type(file_type).unwrap());

        reader.decode().expect("Should decode response to image")
    }

    // Todo test large image upload
}
