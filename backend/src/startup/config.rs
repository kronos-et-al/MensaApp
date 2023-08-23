use std::{env, time::Duration};

use dotenvy::dotenv;
use tracing::info;

use crate::layer::{
    data::{
        database::factory::DatabaseInfo, flickr_api::flickr_api_handler::FlickrInfo,
        mail::mail_info::MailInfo, swka_parser::swka_parse_manager::SwKaInfo,
    },
    trigger::{graphql::server::GraphQLServerInfo, scheduling::scheduler::ScheduleInfo},
};

use super::{
    cli::{HELP, MIGRATE},
    logging::LogInfo,
    server::{Result, ServerError},
};

const DEFAULT_CANTEENS: &str = "mensa_adenauerring,mensa_gottesaue,mensa_moltke,mensa_x1moltkestrasse,mensa_erzberger,mensa_tiefenbronner,mensa_holzgarten";
const DEFAULT_BASE_URL: &str = "https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/";
const DEFAULT_UPDATE_PARSE_SCHEDULE: &str = "0 */15 10-15 * * *";
const DEFAULT_NIGHTLY_SCHEDULE: &str = "0 0 2 * * *";
const DEFAULT_LOG_CONFIG: &str = "warn,mensa_app_backend=info";
const DEFAULT_USER_AGENT: &str = "MensaKa 0.1";
const DEFAULT_CLIENT_TIMEOUT: u64 = 6000;
const DEFAULT_HTTP_PORT: u16 = 80;
const DEFAULT_SMTP_PORT: u16 = 465;
const DEFAULT_PARSE_WEEKS: u32 = 5;

/// Class for reading configuration from environment variables.
pub struct ConfigReader {}

impl Default for ConfigReader {
    fn default() -> Self {
        dotenv().ok();
        Self {}
    }
}

impl ConfigReader {
    /// Checks program arguments whether a migration should get run.
    #[must_use]
    pub fn should_migrate(&self) -> bool {
        env::args().any(|arg| arg == MIGRATE)
    }

    #[must_use]
    pub fn should_print_help(&self) -> bool {
        env::args().any(|arg| HELP.contains(&arg.as_str()))
    }

    /// Reads the logging configuration from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_log_info(&self) -> Result<LogInfo> {
        let info = LogInfo {
            log_config: read_var("LOG_CONFIG").unwrap_or_else(|_| DEFAULT_LOG_CONFIG.into()),
        };
        info!("using log config: {}", info.log_config);
        Ok(info)
    }

    /// Reads the config for accessing the database from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_database_info(&self) -> Result<DatabaseInfo> {
        let info = DatabaseInfo {
            connection: read_var("DATABASE_URL")?,
            max_weeks_data: read_var("PARSE_WEEKS")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(DEFAULT_PARSE_WEEKS),
        };
        Ok(info)
    }

    /// Reads the config for accessing the mail server from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.  
    pub fn read_mail_info(&self) -> Result<MailInfo> {
        let info = MailInfo {
            admin_email_address: read_var("ADMIN_EMAIL")?,
            smtp_server: read_var("SMTP_SERVER")?,
            smtp_port: read_var("SMTP_PORT")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(DEFAULT_SMTP_PORT),
            username: read_var("SMTP_USERNAME")?,
            password: read_var("SMTP_PASSWORD")?,
        };
        Ok(info)
    }

    /// Reads the schedules for regular events from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_schedule_info(&self) -> Result<ScheduleInfo> {
        let info = ScheduleInfo {
            full_parse_schedule: env::var("FULL_PARSE_SCHEDULE")
                .unwrap_or_else(|_| DEFAULT_NIGHTLY_SCHEDULE.into()),
            update_parse_schedule: env::var("UPDATE_PARSE_SCHEDULE")
                .unwrap_or_else(|_| DEFAULT_UPDATE_PARSE_SCHEDULE.into()),
            image_review_schedule: env::var("IMAGE_REVIEW_SCHEDULE")
                .unwrap_or_else(|_| DEFAULT_NIGHTLY_SCHEDULE.into()),
        };
        Ok(info)
    }

    /// Reads the config for the flickr api from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_flickr_info(&self) -> Result<FlickrInfo> {
        let info = FlickrInfo {
            api_key: read_var("FLICKR_API_KEY")?,
        };
        Ok(info)
    }

    /// Reads the config for the homepage of the "Studierendenwerk Karlsruhe" (Sw Ka) and its canteens from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_swka_info(&self) -> Result<SwKaInfo> {
        let timeout = env::var("CLIENT_TIMEOUT")
            .ok()
            .and_then(|s| s.parse().ok())
            .unwrap_or(DEFAULT_CLIENT_TIMEOUT);
        let timeout = Duration::from_millis(timeout);

        let canteens = read_var("CANTEENS")
            .unwrap_or_else(|_| DEFAULT_CANTEENS.into())
            .split(',')
            .map(str::trim)
            .map(String::from)
            .collect();

        let info = SwKaInfo {
            base_url: read_var("MENSA_BASE_URL").unwrap_or_else(|_| DEFAULT_BASE_URL.into()),
            client_timeout: timeout,
            client_user_agent: env::var("USER_AGENT")
                .unwrap_or_else(|_| String::from(DEFAULT_USER_AGENT)),
            valid_canteens: canteens,
            number_of_weeks_to_poll: read_var("PARSE_WEEKS")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(DEFAULT_PARSE_WEEKS),
        };
        info!(
            "getting canteen data from {} for canteens {}",
            info.base_url,
            info.valid_canteens.join(", ")
        );
        Ok(info)
    }

    /// Reads the config for the graphql web server from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_graphql_info(&self) -> Result<GraphQLServerInfo> {
        let info = GraphQLServerInfo {
            port: env::var("HTTP_PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(DEFAULT_HTTP_PORT),
        };
        Ok(info)
    }
}

fn read_var(var: &str) -> Result<String> {
    env::var(var).map_err(|e| ServerError::MissingEnvVar(var.to_string(), e))
}

#[cfg(test)]
mod tests {
    use super::ConfigReader;

    #[test]
    fn test_conf_reader() {
        let reader = ConfigReader::default();
        reader.read_database_info().ok();
        reader.read_flickr_info().ok();
        reader.read_graphql_info().ok();
        reader.read_log_info().ok();
        reader.read_mail_info().ok();
        reader.read_schedule_info().ok();
        reader.read_swka_info().ok();
        let _ = reader.should_migrate();
        let _ = reader.should_print_help();
    }
}
