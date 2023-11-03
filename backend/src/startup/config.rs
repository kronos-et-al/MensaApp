//! See [`ConfigReader`].
use super::{
    cli::{HELP, MIGRATE, MIGRATE_IMAGES},
    logging::LogInfo,
    server::{Result, ServerError},
};
use crate::interface::image_validation::ImageValidationInfo;
use crate::layer::{
    data::{
        database::factory::DatabaseInfo, file_handler::FileHandlerInfo, mail::mail_info::MailInfo,
        swka_parser::swka_parse_manager::SwKaInfo,
    },
    logic::api_command::image_preprocessing::ImagePreprocessingInfo,
    trigger::{api::server::ApiServerInfo, scheduling::scheduler::ScheduleInfo},
};
use dotenvy::dotenv;
use std::{env, num::NonZeroU64, path::PathBuf, time::Duration};
use tracing::info;

const DEFAULT_CANTEENS: &str = "mensa_adenauerring,mensa_gottesaue,mensa_moltke,mensa_x1moltkestrasse,mensa_erzberger,mensa_tiefenbronner,mensa_holzgarten";
const DEFAULT_BASE_URL: &str = "https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/";
const DEFAULT_UPDATE_PARSE_SCHEDULE: &str = "0 */15 7-15 * * *";
const DEFAULT_NIGHTLY_SCHEDULE: &str = "0 0 2 * * *";
const DEFAULT_LOG_CONFIG: &str = "warn,mensa_app_backend=info";
const DEFAULT_USER_AGENT: &str = concat!("MensaKa ", env!("CARGO_PKG_VERSION"));
const DEFAULT_CLIENT_TIMEOUT: u64 = 6000;
const DEFAULT_HTTP_PORT: u16 = 80;
const DEFAULT_SMTP_PORT: u16 = 465;
const DEFAULT_PARSE_WEEKS: u32 = 4;
const DEFAULT_MAX_IMAGE_WIDTH: u32 = 1920;
const DEFAULT_MAX_IMAGE_HEIGHT: u32 = 1080;
const DEFAULT_IMAGE_ACCEPTANCE_VALUES: &str = "0,0,0,0,0";
const DEFAULT_UPLOAD_SIZE: u64 = 10 << 20; // 10 MiB

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

    /// Queries the program arguments to check whether the help page should be shown.
    #[must_use]
    pub fn should_print_help(&self) -> bool {
        env::args().any(|arg| HELP.contains(&arg.as_str()))
    }

    /// Queries the program arguments to check whether image migration should be run.
    #[must_use]
    pub fn should_migrate_images(&self) -> bool {
        env::args().any(|arg| arg == MIGRATE_IMAGES)
    }

    /// Reads the logging configuration from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_log_info(&self) -> Result<LogInfo> {
        // note: no logging here because logging is not yet initialized.
        let info = LogInfo {
            log_config: read_var("LOG_CONFIG").unwrap_or_else(|_| DEFAULT_LOG_CONFIG.into()),
        };
        Ok(info)
    }

    /// Reads the config for accessing the database from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_database_info(&self) -> Result<DatabaseInfo> {
        let info = DatabaseInfo {
            connection: read_var("DATABASE_URL")?,
            max_weeks_data: get_max_weeks_data(),
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
        info!(
            "Sending mails to {} from {} using {}:{}",
            info.admin_email_address, info.username, info.smtp_server, info.smtp_port
        );
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
        };
        info!(
            "Running full parsing on `{}` and update parsing on `{}`",
            info.full_parse_schedule, info.update_parse_schedule
        );
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
            number_of_weeks_to_poll: get_max_weeks_data(),
        };
        info!(
            "getting canteen data from <{}> for canteens {}",
            info.base_url,
            info.valid_canteens.join(", ")
        );
        Ok(info)
    }

    /// Reads the config for the graphql web server from environment variables.
    /// # Errors
    /// when the environment variables are not set and no default is provided internally.
    pub fn read_api_info(&self) -> Result<ApiServerInfo> {
        let info = ApiServerInfo {
            port: env::var("HTTP_PORT")
                .ok()
                .and_then(|p| p.parse().ok())
                .unwrap_or(DEFAULT_HTTP_PORT),
            image_dir: read_var("IMAGE_DIR").map(PathBuf::from)?,
            rate_limit: read_var("RATE_LIMIT")
                .ok()
                .and_then(|r| r.parse().ok())
                .and_then(NonZeroU64::new),
            max_body_size: read_var("MAX_UPLOAD_SIZE")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(DEFAULT_UPLOAD_SIZE),
        };

        info.rate_limit.map_or_else(
            || info!("Using no rate limit."),
            |limit| info!("Using a rate limit of {limit} graphql requests per second"),
        );

        info!("Using max upload size of {} bytes.", info.max_body_size);

        Ok(info)
    }

    /// Reads the config for the image preprocessing.
    #[must_use]
    pub fn read_image_preprocessing_info(&self) -> ImagePreprocessingInfo {
        let info: ImagePreprocessingInfo = ImagePreprocessingInfo {
            max_image_width: env::var("MAX_IMAGE_WIDTH")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(DEFAULT_MAX_IMAGE_WIDTH),
            max_image_height: env::var("MAX_IMAGE_HEIGHT")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(DEFAULT_MAX_IMAGE_HEIGHT),
        };
        info!(
            "Scaling down images to {}x{}",
            info.max_image_width, info.max_image_height
        );
        info
    }

    /// Reads the config for the file handler.
    /// # Errors
    /// - when the environment variable is not set
    /// - when the image directory does not exist
    pub async fn read_file_handler_info(&self) -> Result<FileHandlerInfo> {
        let info: FileHandlerInfo = FileHandlerInfo {
            image_dir: read_var("IMAGE_DIR")?.into(),
        };

        if !tokio::fs::try_exists(&info.image_dir)
            .await
            .unwrap_or_default()
        {
            return Err(ServerError::NonexistingDirectory(
                info.image_dir.to_string_lossy().to_string(),
            ));
        }

        info!("Using and storing images at: {}", info.image_dir.display());

        Ok(info)
    }

    /// Reads the config for the image validation component.
    /// # Errors
    /// - when an environment variable is not set
    /// - when the acceptance values could not be parsed
    pub async fn get_image_validation_info(&self) -> Result<ImageValidationInfo> {
        let project_id = read_var("GOOGLE_PROJECT_ID")?;
        let acceptance = read_acceptence_var("IMAGE_ACCEPTANCE_VALUES")?;
        let service_account_info =
            tokio::fs::read_to_string(read_var("SERVICE_ACCOUNT_JSON")?).await?;
        info!("Using google cloud project '{project_id}' for image verification with the category levels '{acceptance:?}'");
        Ok(ImageValidationInfo {
            acceptance,
            service_account_info,
            project_id,
        })
    }
}

fn read_var(var: &str) -> Result<String> {
    env::var(var).map_err(|e| ServerError::MissingEnvVar(var.to_string(), e))
}

fn read_acceptence_var(key: &str) -> Result<[u8; 5]> {
    let str_arr = read_var(key).unwrap_or_else(|_| DEFAULT_IMAGE_ACCEPTANCE_VALUES.into());

    str_arr
        .split(',')
        .map(str::trim)
        .map(str::parse::<u8>)
        .map(|r| r.ok().and_then(|i| (0..=5).contains(&i).then_some(i)))
        .collect::<Option<Vec<_>>>()
        .and_then(|v| v.try_into().ok())
        .ok_or(ServerError::InvalidFormatError {
            var: key.into(),
            gotten: str_arr,
            expected_format: "`x,x,x,x,x` where x is in `0..=5`".into(),
        })
}

fn get_max_weeks_data() -> u32 {
    read_var("PARSE_WEEKS")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(DEFAULT_PARSE_WEEKS)
        + 1 // +1 for current week
}

#[cfg(test)]
mod tests {
    use tracing_test::traced_test;

    use super::{read_acceptence_var, ConfigReader};

    #[test]
    fn test_read_acceptence_var() {
        let var = "TEST";
        std::env::set_var(var, "1,2, 3 ,4,05");

        let res = read_acceptence_var(var).expect("should parse");
        assert_eq!([1, 2, 3, 4, 5], res);
    }

    #[tokio::test]
    #[traced_test]
    async fn test_conf_reader() {
        let reader = ConfigReader::default();
        reader.read_database_info().ok();
        reader.read_api_info().ok();
        reader.read_log_info().ok();
        reader.read_mail_info().ok();
        reader.read_schedule_info().ok();
        reader.read_swka_info().ok();
        reader.read_file_handler_info().await.ok();
        reader.get_image_validation_info().await.ok();
        let _ = reader.read_image_preprocessing_info();
        let _ = reader.should_migrate();
        let _ = reader.should_print_help();
    }
}
