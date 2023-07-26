use std::{env, time::Duration};

use dotenvy::dotenv;

use crate::layer::{
    data::{
        database::factory::DatabaseInfo, flickr_api::flickr_api_handler::FlickrInfo,
        mail::mail_info::MailInfo, swka_parser::swka_parse_manager::SwKaInfo,
    },
    trigger::{graphql::server::GraphQLServerInfo, scheduling::scheduler::ScheduleInfo},
};

use super::server::{Result, ServerError};

/// Class for reading configuration from environment variables.
pub struct ConfigReader {}

impl Default for ConfigReader {
    fn default() -> Self {
        dotenv().ok();
        Self {}
    }
}

impl ConfigReader {
    /// Reads the config for accessing the database from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_database_info(&self) -> Result<DatabaseInfo> {
        let info = DatabaseInfo {
            connection: read_var("DATABASE_URL")?,
        };
        Ok(info)
    }

    /// Reads the config for accessing the mail server from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_mail_info(&self) -> Result<MailInfo> {
        let info = MailInfo {
            admin_email_address: read_var("ADMIN_EMAIL")?,
            smtp_server: read_var("SMTP_SERVER")?,
            smtp_port: read_var("SMTP_PORT")?.parse().unwrap_or(465),
            username: read_var("SMTP_USERNAME")?,
            password: read_var("SMTP_PASSWORD")?,
        };
        Ok(info)
    }

    /// Reads the schedules for regular events from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_schedule_info(&self) -> Result<ScheduleInfo> {
        let info = ScheduleInfo {
            full_parse_schedule: env::var("FULL_PARSE_SCHEDULE")
                .unwrap_or_else(|_| "0 0 2 * * *".into()),
            update_parse_schedule: env::var("UPDATE_PARSE_SCHEDULE")
                .unwrap_or_else(|_| "0 */15 10-15 * * *".into()),
            image_review_schedule: env::var("IMAGE_REVIEW_SCHEDULE")
                .unwrap_or_else(|_| "0 0 2 * * *".into()),
        };
        Ok(info)
    }

    /// Reads the config for the flickr api from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_flickr_info(&self) -> Result<FlickrInfo> {
        let info = FlickrInfo {
            api_key: read_var("FLICKR_API_KEY")?,
        };
        Ok(info)
    }

    /// Reads the config for the homepage of the "Studierendenwerk Karlsruhe" (Sw Ka) and its canteens from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_swka_info(&self) -> Result<SwKaInfo> {
        let timeout = env::var("CLIENT_TIMEOUT")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(6000);
        let timeout = Duration::from_millis(timeout);

        let canteens = read_var("CANTEENS")?
            .split(',')
            .map(str::trim)
            .map(String::from)
            .collect();

        let info = SwKaInfo {
            base_url: read_var("MENSA_BASE_URL")?,
            client_timeout: timeout,
            client_user_agent: env::var("USER_AGENT").unwrap_or_default(),
            valid_canteens: canteens,
        };
        Ok(info)
    }

    /// Reads the config for the graphql web server from environment variables.
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_graphql_info(&self) -> Result<GraphQLServerInfo> {
        let info = GraphQLServerInfo {
            port: env::var("HTTP_PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(80),
        };
        Ok(info)
    }
}

fn read_var(var: &str) -> Result<String> {
    env::var(var).map_err(|e| ServerError::MissingEnvVar(var.to_string(), e))
}
