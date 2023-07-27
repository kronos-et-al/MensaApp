#[tokio::main]
async fn main() {
    mensa_app_backend::Server::run().await.unwrap();
}
