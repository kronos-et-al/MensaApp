//! This module contains the server, the heart of the application.
use std::{env::VarError, num::ParseIntError};
use thiserror::Error;
use tokio::signal::ctrl_c;
use tracing::info;

use crate::{
    interface::{api_command::CommandError, mensa_parser::ParseError, persistent_data::DataError},
    layer::{
        data::{
            database::factory::DataAccessFactory,
            mail::mail_sender::{MailError, MailSender},
            swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::{
            api_command::{
                command_handler::CommandHandler,
                mocks::{CommandImageStorageMock, CommandImageValidationMock},
            },
            mealplan_management::meal_plan_manager::MealPlanManager,
        },
        trigger::{api::server::ApiServer, scheduling::scheduler::Scheduler},
    },
    startup::{cli, config::ConfigReader, logging::Logger},
};

/// Result returned from the server, potentially containing a [`ServerError`].
pub type Result<T> = std::result::Result<T, ServerError>;

/// Error indicating that there was an error while starting/stopping the server.
#[derive(Debug, Error)]
pub enum ServerError {
    /// A necessary environment variable was not set.
    #[error("the following environment variable must be set: {0}")]
    MissingEnvVar(String, VarError),
    /// Error while creating the mail sender.
    #[error("error while creating mail sender component: {0}")]
    MailError(#[from] MailError),
    /// Error while creating command component.
    #[error("error cwhile reating command component: {0}")]
    CommandError(#[from] CommandError),
    /// Error while creating mensa parser component.
    #[error("error while creating mensa parser component: {0}")]
    ParseError(#[from] ParseError),
    /// Io error
    #[error("io error: {0}")]
    IoError(#[from] std::io::Error),
    /// Error parsing integers.
    #[error("could not parsing integer: {0}")]
    ParseIntError(#[from] ParseIntError),
    /// Error from the database.
    #[error("error from the database: {0}")]
    DataError(#[from] DataError),
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

        // data layer
        let factory =
            DataAccessFactory::new(config.read_database_info()?, config.should_migrate()).await?;
        let command_data = factory.get_command_data_access();
        let mealplan_management_data = factory.get_mealplan_management_data_access();
        let request_data = factory.get_request_data_access();

        let mail = MailSender::new(config.read_mail_info()?)?;
        let parser = SwKaParseManager::new(config.read_swka_info()?)?;
        let file_handler = CommandImageStorageMock; // todo
        let google_vision = CommandImageValidationMock; // todo

        // logic layer
        let command = CommandHandler::new(
            config.read_image_preprocessing_info(),
            command_data,
            mail,
            file_handler,
            google_vision,
        )
        .await?;
        let mealplan_management = MealPlanManager::new(mealplan_management_data, parser);

        // trigger layer
        let mut graphql = ApiServer::new(config.read_api_info()?, request_data, command);
        let mut scheduler = Scheduler::new(config.read_schedule_info()?, mealplan_management).await;

        // run server
        scheduler.start().await;
        graphql.start();

        info!("Server is running");

        ctrl_c().await?;

        info!("Shutting down server...");

        scheduler.shutdown().await;
        graphql.shutdown().await;

        info!("Server stopped.");

        Ok(())
    }
}
