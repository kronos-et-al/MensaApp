//! This module contains the server, the heart of the application.
use tokio::signal::ctrl_c;
use tracing::info;

use mensa_app_backend::{
    layer::{
        data::{
            database::factory::DataAccessFactory, swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::{
            api_command::{
                command_handler::CommandHandler,
                mocks::{
                    CommandAdminNotificationMock, CommandImageStorageMock,
                    CommandImageValidationMock,
                },
            },
            mealplan_management::meal_plan_manager::MealPlanManager,
        },
        trigger::{api::server::ApiServer, scheduling::scheduler::Scheduler},
    },
    startup::{cli, config::ConfigReader, logging::Logger, server::ServerError},
};

/// Result returned from the server, potentially containing a [`ServerError`].
pub type Result<T> = std::result::Result<T, ServerError>;
/// Runs the server and everything that belongs to.
/// Therefore the configuration is read from environment variables.
/// Afterwards, the component structure is created.
/// # Errors
/// - when the the config could not read environment variables
/// - when crating a component fails
#[tokio::main]
async fn main() {
    run().await.unwrap();
}

async fn run() -> Result<()> {
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
    let factory = DataAccessFactory::new(config.read_database_info()?).await?;
    let command_data = factory.get_command_data_access();
    let mealplan_management_data = factory.get_mealplan_management_data_access();
    let request_data = factory.get_request_data_access();
    let auth_data = factory.get_auth_data_access();

    let mail = CommandAdminNotificationMock;
    let parser = SwKaParseManager::new(config.read_swka_info()?)?;
    let file_handler = CommandImageStorageMock;
    let google_vision = CommandImageValidationMock;

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
    api_server.start().await;

    info!("Server is running");

    ctrl_c().await?;

    info!("Shutting down server...");

    scheduler.shutdown().await;
    api_server.shutdown().await;

    info!("Server stopped.");
    Ok(())
}
