use mensa_app_backend::startup::server::ServerError;

#[tokio::main]
async fn main() -> Result<(), ServerError> {
    mensa_app_backend::Server::run().await
}
