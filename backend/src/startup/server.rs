//! This module contains the server, the heart of the application.
use std::fmt::{Debug, Display};
use std::{env::VarError, num::ParseIntError};
use thiserror::Error;
use tokio::signal::ctrl_c;
use tracing::info;

use crate::interface::image_validation::ImageValidationError;
use crate::layer::data::image_validation::google_api_handler::GoogleApiHandler;
use crate::{
    interface::{api_command::CommandError, mensa_parser::ParseError, persistent_data::DataError},
    layer::{
        data::{
            database::factory::DataAccessFactory,
            file_handler::FileHandler,
            mail::mail_sender::{MailError, MailSender},
            swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::{
            api_command::command_handler::CommandHandler,
            mealplan_management::meal_plan_manager::MealPlanManager,
        },
        trigger::{api::server::ApiServer, scheduling::scheduler::Scheduler},
    },
    startup::{cli, config::ConfigReader, logging::Logger},
};

use super::cli::SubcommandError;

/// Result returned from the server, potentially containing a [`ServerError`].
pub type Result<T> = std::result::Result<T, ServerError>;

/// Error indicating that there was an error while starting/stopping the server.
#[derive(Error)]
pub enum ServerError {
    /// A necessary environment variable was not set.
    #[error("the following environment variable must be set: {0}")]
    MissingEnvVar(String, VarError),
    /// A environment variable is not formatted correctly.
    #[error(
        "The env var '{var}' is in the wrong format: got `{gotten}` but expected {expected_format}"
    )]
    InvalidFormatError {
        /// environment variable this error applies to
        var: String,
        /// gotten value in environment variable
        gotten: String,
        /// expected format description
        expected_format: String,
    },
    /// Error while creating the mail sender.
    #[error("error while creating mail sender component: {0}")]
    MailError(#[from] MailError),
    /// Error while creating command component.
    #[error("error cwhile reating command component: {0}")]
    CommandError(#[from] CommandError),
    /// Error while creating mensa parser component.
    #[error("error while creating mensa parser component: {0}")]
    ParseError(#[from] ParseError),
    /// Error while creating image_validation component.
    #[error("error while creating image_validation component: {0}")]
    ValidationApiError(#[from] ImageValidationError),
    /// Io error
    #[error("io error: {0}")]
    IoError(#[from] std::io::Error),
    /// Error parsing integers.
    #[error("could not parsing integer: {0}")]
    ParseIntError(#[from] ParseIntError),
    /// Error from the database.
    #[error("error from the database: {0}")]
    DataError(#[from] DataError),
    /// Error when an directory, eg. the image directory does not exists.
    #[error("the following directory does not exist, but is required: {0}")]
    NonexistingDirectory(String),
    /// Error when running a subcommand.
    #[error("error when executing subcommand: {0}")]
    SubcommandError(#[from] SubcommandError),
}

impl Debug for ServerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        Display::fmt(&self, f)
    }
}

/// Class providing the combined server functions to the outside.
pub struct Server;

impl Server {
    /// Runs the server and everything that belongs to.
    /// Therefore the configuration is read from environment variables.
    /// Afterwards, the component structure is created.
    /// # Errors
    /// - when the the config could not read environment variables
    /// - when crating a component fails
    #[allow(clippy::cognitive_complexity)]
    pub async fn run() -> Result<()> {
        let config = ConfigReader::default();

        // logging
        Logger::init(config.read_log_info()?);

        info!("Starting server...");

        // help text
        if config.should_print_help() {
            cli::print_help();
            return Ok(());
        }

        if config.should_migrate_images() {
            cli::migrate_images(&config).await?;
            return Ok(());
        }

        // data layer
        let factory =
            DataAccessFactory::new(config.read_database_info()?, config.should_migrate()).await?;
        let command_data = factory.get_command_data_access();
        let mealplan_management_data = factory.get_mealplan_management_data_access();
        let request_data = factory.get_request_data_access();
        let auth_data = factory.get_auth_data_access();

        let mail = MailSender::new(config.read_mail_info()?)?;
        let parser = SwKaParseManager::new(config.read_swka_info()?)?;
        let file_handler = FileHandler::new(config.read_file_handler_info().await?);
        let google_vision = GoogleApiHandler::new(config.get_image_validation_info().await?)?;

        // logic layer
        let command = CommandHandler::new(
            config.read_image_preprocessing_info(),
            command_data,
            mail,
            file_handler,
            google_vision,
        )?;
        let mealplan_management = MealPlanManager::new(mealplan_management_data, parser);

        // trigger layer
        let mut api_server =
            ApiServer::new(config.read_api_info()?, request_data, command, auth_data).await;
        let mut scheduler = Scheduler::new(config.read_schedule_info()?, mealplan_management).await;

        // run server
        scheduler.start().await;
        api_server.start();

        info!("Server is running");

        ctrl_c().await?;

        info!("Shutting down server...");

        scheduler.shutdown().await;
        api_server.shutdown().await;

        info!("Server stopped.");

        Ok(())
    }
}
