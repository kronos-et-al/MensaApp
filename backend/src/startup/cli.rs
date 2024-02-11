//! Module containing code for command line-only actions.

use colored::Colorize;
use futures::StreamExt;
use hyper::{header::CONTENT_TYPE, Method};
use thiserror::Error;
use tracing::{info, warn};

use crate::{
    interface::image_storage::{self, ImageStorage},
    layer::{
        data::file_handler::FileHandler,
        logic::api_command::image_preprocessing::{ImagePreprocessingError, ImagePreprocessor},
    },
};

use super::{config::ConfigReader, server::ServerError};

/// Error while running a subcommand.
#[derive(Debug, Error)]
pub enum SubcommandError {
    /// Error accessing database while running a subcommand.
    #[error("error accessing database: {0}")]
    DatabaseError(#[from] sqlx::Error),
    /// Error while reading config.
    #[error("error while reading config: {0}")]
    ServerError(#[from] Box<ServerError>),
    /// Error while requesting image from the web.
    #[error("error while requesting image file: {0}")]
    ReqwestError(#[from] reqwest::Error),
    /// Error while preprocessing image.
    #[error("error while preprocessing an image: {0}")]
    ImagePreprocessError(#[from] ImagePreprocessingError),
    /// Error while storing image locally.
    #[error("could not save image")]
    ImageStorageError(#[from] image_storage::ImageError),
}

/// Command arguments to show the help page.
pub const HELP: &[&str] = &["--help", "-h", "-?"];
/// Command argument to run database migrations.
pub const MIGRATE: &str = "--migrate";

/// Command arguments to igrate images from image hoster (flickr) to local storage.
pub const MIGRATE_IMAGES: &str = "--migrate-images";

/// Prints information about the binary and shows available commands.
pub fn print_help() {
    const COMMAND_WIDTH: usize = 20;
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!(
        "{}",
        format!("   MensaApp Backend v{} 🥘  ", env!("CARGO_PKG_VERSION")).green()
    );
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!("This binary runs the backend to for the mensa app,");
    println!("including a graphql server.");
    println!("For more information, ");
    println!("see {}", env!("CARGO_PKG_REPOSITORY"));
    println!();
    println!(
        "{}",
        format!("Licensed under the {} license.", env!("CARGO_PKG_LICENSE")).italic()
    );
    println!();
    println!();
    println!("{}", "Available commands:".blue());
    println!(
        "{:<COMMAND_WIDTH$} {}",
        "help".bold(),
        HELP.join(" ").as_str().bright_black()
    );
    println!("          shows this page");
    println!();
    println!(
        "{:<COMMAND_WIDTH$} {}",
        "migrate".bold(),
        MIGRATE.bright_black()
    );
    println!("          runs the database migrations");
    println!("          before continuing like normal");
    println!();
    println!(
        "{:<COMMAND_WIDTH$} {}",
        "migrate images".bold(),
        MIGRATE_IMAGES.bright_black()
    );
    println!("          migrates images from hoster");
    println!("          to local storage");
    println!();
}

/// migrates images from image hoster to local storage.
/// # Errors
/// - invalid file config
/// - invalid database config
/// # Panics
/// never
pub async fn migrate_images(config: &ConfigReader) -> Result<(), SubcommandError> {
    info!("Starting image migration...");

    let image_preprocessing = ImagePreprocessor::new(config.read_image_preprocessing_info());
    let file_handler = FileHandler::new(config.read_file_handler_info().await.map_err(Box::new)?);

    let database_config = config.read_database_info().map_err(Box::new)?;

    let pool = sqlx::postgres::PgPool::connect(&database_config.connection).await?;

    let client = reqwest::Client::new();

    sqlx::query!("SELECT image_id, url FROM image WHERE url IS NOT NULL")
        .fetch(&pool)
        .map(|res| async {
            tracing::trace!("migrating {res:?}");
            let record = res?;
            let image_id = record.image_id;

            let response = client.request(Method::GET, record.url).send().await?;

            let image_type = response
                .headers()
                .get(CONTENT_TYPE)
                .and_then(|c| c.to_str().ok())
                .map(String::from);

            let image_data = response.bytes().await?.into_iter().collect::<Vec<_>>();

            let image = image_preprocessing.preprocess_image(image_data, image_type)?;

            file_handler.save_image(image_id, image).await?;

            sqlx::query!(
                "UPDATE image SET url = NULL, id = NULL WHERE image_id = $1",
                image_id
            )
            .execute(&pool)
            .await?;

            Ok::<_, SubcommandError>(image_id)
        })
        .for_each(|res| async {
            match res.await {
                Ok(id) => info!("Sucessfully downloaded image {id}."),
                Err(err) => warn!("Error while loading an image: {err}"),
            }
        })
        .await;

    let remaining = sqlx::query_scalar!("SELECT COUNT(*) FROM image WHERE url IS NOT NULL")
        .fetch_one(&pool)
        .await?
        .expect("not null by query");

    info!("Migration done! {remaining} un-migrated images left.");

    Ok(())
}

#[cfg(test)]
mod tests {

    use crate::startup::config::ConfigReader;

    use super::{migrate_images, print_help};

    #[test]
    fn test_print_cli() {
        print_help();
    }

    #[tokio::test]
    async fn test_migrate_images() {
        let dir = tempfile::tempdir().expect("tempdir available");
        std::env::set_var("IMAGE_DIR", dir.path().as_os_str());
        let reader = ConfigReader::default();
        migrate_images(&reader).await.expect("ok");
    }
}
