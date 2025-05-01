//! This package contains the server that is responsible for providing the graphql and image API.

use std::{
    fmt::Display,
    future::{Future, IntoFuture},
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
    BoxError, Extension, Router,
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
    layer::trigger::api::{
        admin::{admin_router, ArcCommand},
        auth::auth_middleware,
    },
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
    /// Api key for accessing the admin api
    pub admin_key: String,
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
    command_copy: Arc<dyn Command + Send + Sync>,
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
        let command_arc = Arc::new(command);
        let schema: GraphQLSchema = construct_schema(data_access, command_arc.clone());
        Self {
            server_info,
            schema,
            state: State::Created,
            api_keys: auth
                .get_api_keys()
                .await
                .expect("could not get api keys from database"),
            command_copy: command_arc,
        }
    }

    /// Starts the GraphQL-Server. It will be running in the background until [`Self::shutdown()`] is called.
    ///
    /// # Panics
    /// This function panics if the server is in the wrong state, meaning it is already running or shut down.
    pub async fn start(&mut self) {
        assert!(
            matches!(self.state, State::Created),
            "tried to start graphql server while in state {}",
            self.state
        );

        let max_body_size = self
            .server_info
            .max_body_size
            .try_into()
            .expect("max body size should fit in usize");

        let auth =
            middleware::from_fn_with_state((max_body_size, self.api_keys.clone()), auth_middleware);

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

        let admin_router = admin_router(
            self.server_info.admin_key.clone(),
            self.command_copy.clone() as ArcCommand,
        );

        let app = Router::new()
            .route(
                "/",
                get(graphql_playground).post(graphql_handler.layer(auth)),
            )
            .layer(Extension(self.schema.clone()))
            .nest("/admin", admin_router)
            .nest_service(IMAGE_BASE_PATH, ServeDir::new(&self.server_info.image_dir))
            .layer(rate_limit)
            .layer(DefaultBodyLimit::max(max_body_size));

        let socket = std::net::SocketAddr::V6(SocketAddrV6::new(
            Ipv6Addr::UNSPECIFIED,
            self.server_info.port,
            0,
            0,
        ));

        let listener = tokio::net::TcpListener::bind(socket)
            .await
            .expect("bind to tcp socket");
        let server = axum::serve(listener, app);

        let shutdown_notify = Arc::new(Notify::new());
        let shutdown_notify_sender = shutdown_notify.clone();

        let with_shutdown =
            server.with_graceful_shutdown(async move { shutdown_notify_sender.notified().await });

        let join_handle = tokio::spawn(with_shutdown.into_future());

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
    data_access: impl RequestDataAccess + 'static,
    command: impl Command + 'static,
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
            debug!(
                "Error handling request: {}",
                response
                    .errors
                    .iter()
                    .map(|e| e.message.to_string())
                    .collect::<Vec<_>>()
                    .join("\n")
            );
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
    use base64::{engine::general_purpose, Engine};
    use hmac::{Hmac, Mac};
    use image::{DynamicImage, ImageBuffer, ImageFormat, ImageReader};
    use reqwest::header::{AUTHORIZATION, CONTENT_TYPE};
    use serial_test::serial;
    use sha2::{Digest, Sha512};

    use crate::{
        layer::trigger::api::{
            mock::{AuthDataMock, CommandMock, RequestDatabaseMock},
            server::ApiServer,
        },
        util::{ImageResource, Uuid},
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
            admin_key: "admin".into(),
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock).await
    }

    async fn get_test_server_with_images(image_dir: PathBuf) -> ApiServer {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir,
            rate_limit: None,
            max_body_size: BODY_SIZE,
            admin_key: "admin".into(),
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock).await
    }

    #[tokio::test]
    #[serial]
    /// Test whether api version is available as health check.
    async fn test_graphql() {
        let mut server = get_test_server().await;
        server.start().await;

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
        server.start().await;

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
    #[should_panic = "tried to shutdown server but in state finished"]
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
        server.start().await;
        server.start().await;
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
        server.start().await;

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
        let mut reader = ImageReader::new(Cursor::new(&resp_bytes));
        reader.set_format(ImageFormat::from_mime_type(file_type).unwrap());

        reader.decode().expect("Should decode response to image")
    }

    #[tokio::test]
    #[serial]
    async fn test_large_image_upload() {
        let mut server = get_test_server().await;
        server.start().await;

        let image = include_bytes!("test_data/test_real.jpg").as_ref();

        let hash = Sha512::new().chain_update(image).finalize().to_vec();
        let base64_hash = general_purpose::STANDARD.encode(hash);

        let operations = [b"{\"operationName\":null,\"variables\":{\"mealId\":\"bd3c88f9-5dc8-4773-85dc-53305930e7b6\",\"image\":null, \"hash\": \"".as_ref(), 
        base64_hash.as_bytes(),
        b"\"},\"query\":\"mutation LinkImage($mealId: UUID!, $image: Upload!, $hash: String!) {\\n  __typename\\n  addImage(mealId: $mealId, image: $image, hash: $hash)\\n}\"}"].concat();

        let api_key = "1234567890";
        let hmac = Hmac::<Sha512>::new_from_slice(api_key.as_bytes())
            .unwrap()
            .chain_update(&operations)
            .finalize()
            .into_bytes()
            .to_vec();

        let hmac_base64 = general_purpose::STANDARD.encode(hmac);
        let client_id = Uuid::default();
        let auth = format!("{client_id}:{api_key}:{hmac_base64}");
        let auth = general_purpose::STANDARD.encode(auth.as_bytes());

        let test_request = [b"--boundary\r\nContent-Disposition: form-data; name=\"operations\"\r\n\r\n".as_ref(), &operations, b"\r\n--boundary\r\nContent-Disposition: form-data; name=\"map\"\r\n\r\n{\"0\":[\"variables.image\"]}\r\n--boundary\r\ncontent-type: image/jpeg\r\ncontent-disposition: form-data; name=\"0\"; filename=\"a\"\r\n\r\n".as_ref(), 
        image,
        b"\r\n--boundary--".as_ref()].concat();

        let client = reqwest::Client::new();
        let resp = client
            .post(format!("http://localhost:{TEST_PORT}"))
            .header(AUTHORIZATION, format!("Mensa {auth}"))
            .header(CONTENT_TYPE, "multipart/form-data; boundary=boundary")
            .body(test_request)
            .send()
            .await
            .unwrap()
            .text()
            .await
            .unwrap();

        assert_eq!(
            "{\"data\":{\"__typename\":\"MutationRoot\",\"addImage\":true}}", resp,
            "wrong data returned on graphql upload image check."
        );

        server.shutdown().await;
    }

    #[tokio::test]
    #[serial]
    async fn test_too_large_image_upload() {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir: temp_dir(),
            rate_limit: None,
            max_body_size: 1 << 10,
            admin_key: "admin".into(),
        };
        let mut server = ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock).await;

        server.start().await;

        let image = include_bytes!("test_data/test_real.jpg").as_ref();

        let hash = Sha512::new().chain_update(image).finalize().to_vec();
        let base64_hash = general_purpose::STANDARD.encode(hash);

        let operations = [b"{\"operationName\":null,\"variables\":{\"mealId\":\"bd3c88f9-5dc8-4773-85dc-53305930e7b6\",\"image\":null, \"hash\": \"".as_ref(), 
        base64_hash.as_bytes(),
        b"\"},\"query\":\"mutation LinkImage($mealId: UUID!, $image: Upload!, $hash: String!) {\\n  __typename\\n  addImage(mealId: $mealId, image: $image, hash: $hash)\\n}\"}"].concat();

        let api_key = "1234567890";
        let hmac = Hmac::<Sha512>::new_from_slice(api_key.as_bytes())
            .unwrap()
            .chain_update(&operations)
            .finalize()
            .into_bytes()
            .to_vec();

        let hmac_base64 = general_purpose::STANDARD.encode(hmac);
        let client_id = Uuid::default();
        let auth = format!("{client_id}:{api_key}:{hmac_base64}");
        let auth = general_purpose::STANDARD.encode(auth.as_bytes());

        let test_request = [b"--boundary\r\nContent-Disposition: form-data; name=\"operations\"\r\n\r\n".as_ref(), &operations, b"\r\n--boundary\r\nContent-Disposition: form-data; name=\"map\"\r\n\r\n{\"0\":[\"variables.image\"]}\r\n--boundary\r\ncontent-type: image/jpeg\r\ncontent-disposition: form-data; name=\"0\"; filename=\"a\"\r\n\r\n".as_ref(), 
        image,
        b"\r\n--boundary--\r\n".as_ref()].concat();

        let client = reqwest::Client::new();

        let send = client
            .post(format!("http://localhost:{TEST_PORT}"))
            .header(AUTHORIZATION, format!("Mensa {auth}"))
            .header(CONTENT_TYPE, "multipart/form-data; boundary=boundary")
            .body(test_request)
            .send()
            .await;

        assert!(
            send.is_err()
                || send.unwrap().text().await.unwrap()
                    == "could not read body: length limit exceeded"
        );

        server.shutdown().await;
    }
}
