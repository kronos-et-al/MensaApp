use std::sync::Arc;
use thiserror::Error;
use tokio::signal::ctrl_c;

use crate::{
    interface::{
        api_command::{Command, CommandError},
        image_review, mealplan_management,
        mensa_parser::ParseError,
    },
    layer::{
        data::{
            database::factory::DataAccessFactory,
            flickr_api::flickr_api_handler::FlickeApiHandler,
            mail::mail_sender::{MailError, MailSender},
            swka_parser::swka_parse_manager::SwKaParseManager,
        },
        logic::{
            api_command::command_handler::CommandHandler,
            image_review::image_reviewer::ImageReviewer,
            mealplan_management::meal_plan_manager::MealPlanManager,
        },
        trigger::{graphql::server::GraphQLServer, scheduling::scheduler::Scheduler},
    },
    startup::{config::ConfigReader, logging::Logger},
};

pub type Result<T> = std::result::Result<T, ServerError>;

#[derive(Debug, Error)]
pub enum ServerError {
    /// A necessary environment variable was not set.
    #[error("missing environment variable for: ")]
    MissingEnvVar,
    /// Error while creating the mail sender.
    #[error("error while creating mail sender component: {0}")]
    MailError(#[from] MailError),
    /// Error while creating command component.
    #[error("error cwhile reating command component: {0}")]
    CommandError(#[from] CommandError),
    /// Error while creating mensa parser component.
    #[error("error while creating mensa parser component: {0}")]
    ParseError(#[from] ParseError),
}

// Class providing the combined server functions to the outside.
pub struct Server;

impl Server {
    /// Runs the server and everything that belongs to.
    /// Therefore the configuration is read from environment variables.
    /// Afterwards, the component structure is created.
    pub async fn run() -> Result<()> {
        Logger::init();

        // data layer
        let factory = DataAccessFactory::new(ConfigReader::read_database_info()?).await;
        let command_data = factory.get_command_data_access();
        let image_review_data = factory.get_image_review_data_access();
        let mealplan_management_data = factory.get_mealplan_management_data_access();
        let request_data = factory.get_request_data_access();

        let mail = MailSender::new(ConfigReader::read_mail_info()?)?;
        let flickr = FlickeApiHandler::new(ConfigReader::read_flickr_info()?);
        let flickr = Arc::new(flickr);
        let parser = SwKaParseManager::new(ConfigReader::read_swka_info()?)?;

        // logic layer
        let command = CommandHandler::new(command_data, mail, flickr.clone()).await?;
        let image_review = ImageReviewer::new(image_review_data, flickr);
        let mealplan_management = MealPlanManager::new(mealplan_management_data, parser);

        // trigger layer
        let mut graphql = GraphQLServer::new(ConfigReader::read_graphql_info()?, request_data, command);
        let mut scheduler = Scheduler::new(
            ConfigReader::read_schedule_info()?,
            image_review,
            mealplan_management,
        ).await;

        // run server
        scheduler.start().await;
        graphql.start();

        ctrl_c().await;

        scheduler.shutdown();
        graphql.shutdown();

        Ok(())
    }
}
