//! This package contains the server that is responsible for providing the graphql and image API.

use std::{
    fmt::Display,
    future::Future,
    mem,
    net::{Ipv6Addr, SocketAddrV6},
    path::PathBuf,
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
    extract::FromRequest,
    handler::Handler,
    headers::{authorization::Credentials, Authorization, ContentDisposition, ContentType},
    http::{
        request::{self, Parts},
        HeaderMap, Request,
    },
    middleware::{self, Next},
    response::{self, IntoResponse},
    routing::get,
    Extension, Router, Server, TypedHeader,
};
use base64::{engine::general_purpose::STANDARD, Engine};
use hmac::{Hmac, Mac};
use hyper::body::Bytes;
use mime::Mime;
use reqwest::header::AUTHORIZATION;
use sha2::Sha512;
use tokio::sync::Notify;
use tower_http::services::ServeDir;
use tracing::{debug, info, info_span, warn, Instrument};

use crate::{
    interface::{
        api_command::{AuthInfo, Command, InnerAuthInfo},
        persistent_data::{AuthDataAccess, RequestDataAccess},
    },
    util::{local_to_global_url, Uuid, IMAGE_BASE_PATH},
};

use super::{
    mutation::MutationRoot,
    query::QueryRoot,
    util::{read_auth_from_header, CommandBox, DataBox},
};

type GraphQLSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

/// Information necessary to create a [`ApiServerInfo`].
pub struct ApiServerInfo {
    /// Port under which the server should run.
    pub port: u16,
    /// Directory where images are stored.
    pub image_dir: PathBuf,
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
pub struct ApiServer<Auth: AuthDataAccess + 'static> {
    server_info: ApiServerInfo,
    schema: GraphQLSchema,
    state: State,
    auth_data: Arc<Auth>,
}

impl<Auth: AuthDataAccess + 'static> ApiServer<Auth> {
    /// Creates a new Object with given access to datastore and logic for commands.
    pub fn new(
        server_info: ApiServerInfo,
        data_access: impl RequestDataAccess + Sync + Send + 'static,
        command: impl Command + Sync + Send + 'static,
        auth: Auth,
    ) -> Self {
        let schema: GraphQLSchema = construct_schema(data_access, command);
        Self {
            server_info,
            schema,
            state: State::Created,
            auth_data: Arc::new(auth),
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

        let auth = middleware::from_fn(auth_middleware);

        let app = Router::new()
            .route(
                "/",
                get(graphql_playground).post(graphql_handler.layer(auth)),
            )
            .layer(Extension(self.schema.clone()))
            .with_state(self.auth_data.clone())
            .nest_service(IMAGE_BASE_PATH, ServeDir::new(&self.server_info.image_dir));

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
    headers: HeaderMap,
    Extension(auth2): Extension<AuthInfo2>,
    Extension(schema): Extension<GraphQLSchema>,
    request: GraphQLRequest,
) -> GraphQLResponse {
    let auth_header = headers
        .get(AUTHORIZATION)
        .and_then(|h| h.to_str().ok())
        .unwrap_or_default()
        .to_string();

    let auth_info = read_auth_from_header(&auth_header);
    let auth_info_string = auth_info
        .as_ref()
        .map_or("no auth info provided".into(), ToString::to_string);

    let request = request.into_inner().data(auth_info as AuthInfo);

    let span = info_span!(
        "incoming graphql request",
        variables = %request.variables,
        auth_info = auth_info_string
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

impl Credentials for InnerAuthInfo {
    const SCHEME: &'static str = "Mensa";

    fn decode(value: &axum::http::HeaderValue) -> Option<Self> {
        value.to_str().ok().and_then(read_auth_from_header)
    }

    fn encode(&self) -> axum::http::HeaderValue {
        todo!() // todo if necessary
    }
}

#[derive(Debug, Clone)]
pub struct AuthInfo2 {
    // todo rename
    client_id: Option<Uuid>,
    authenticated: bool,
}

async fn auth_middleware(
    TypedHeader(content_type): TypedHeader<ContentType>,
    auth: Option<TypedHeader<Authorization<InnerAuthInfo>>>,
    req: Request<axum::body::Body>,
    next: Next<axum::body::Body>,
) -> impl IntoResponse {
    let auth: AuthInfo = auth.map(|a| a.0 .0);
    let (parts, body) = req.into_parts();
    let bytes = hyper::body::to_bytes(body).await.unwrap();

    let mime = Mime::from(content_type);

    // todo error handling

    let hash_bytes = if mime.essence_str() == mime::MULTIPART_FORM_DATA.essence_str() {
        // copy parts
        let mut parts_builder = request::Builder::new()
            .method(parts.method.clone())
            .uri(parts.uri.clone())
            .version(parts.version.clone());
        parts_builder
            .headers_mut()
            .unwrap()
            .extend(parts.headers.clone());
        let parts = parts_builder.body(()).unwrap().into_parts().0;

        // inspect copy of multipart request
        let req = Request::from_parts(parts, hyper::Body::from(bytes.clone()));
        let mut multipart = axum::extract::Multipart::from_request(req, &())
            .await
            .unwrap();

        let mut bytes = Bytes::default();
        while let Ok(Some(field)) = multipart.next_field().await {
            if field.name() == Some("operations") {
                bytes = field.bytes().await.unwrap();
            }
        }

        bytes
    } else {
        bytes.clone()
    };

    // check hash
    let mut auth2 = AuthInfo2 {
        client_id: auth.as_ref().map(|a| a.client_id),
        authenticated: false,
    };

    if let Some(auth) = auth {
        if !auth.api_ident.is_empty() && !auth.hash.is_empty() {
            let api_key = ""; // todo get api key from db
            let mut hmac = Hmac::<Sha512>::new_from_slice(api_key.as_bytes()).unwrap();
            hmac.update(&bytes);
            let hash = hmac.finalize().into_bytes().to_vec();

            let given_hash = STANDARD.decode(auth.hash).unwrap();

            if hash == given_hash {
                auth2.authenticated = true;
            }
        }
    }

    let mut req = Request::from_parts(parts, hyper::Body::from(bytes));
    req.extensions_mut().insert(auth2);
    next.run(req).await
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

    fn get_test_server() -> ApiServer<AuthDataMock> {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir: temp_dir(),
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock)
    }

    fn get_test_server_with_images(image_dir: PathBuf) -> ApiServer<AuthDataMock> {
        let info = ApiServerInfo {
            port: TEST_PORT,
            image_dir,
        };
        ApiServer::new(info, RequestDatabaseMock, CommandMock, AuthDataMock)
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

        let mut server = get_test_server_with_images(image_folder.path().to_owned());
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
}
