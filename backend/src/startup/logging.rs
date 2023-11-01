//! Module for setting up the logging framework.
use chrono::Local;
use time::{format_description::well_known::Rfc2822, UtcOffset};
use tracing::info;
use tracing_subscriber::{fmt::time::OffsetTime, EnvFilter, FmtSubscriber};

/// Struct containing all configurations available for the logging system.
pub struct LogInfo {
    /// Logging specifier following the schema of <https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html>
    pub log_config: String,
}

/// Class for initializing the logging.
pub struct Logger;

impl Logger {
    /// Initializes the logger.
    ///
    /// # Panics
    /// if the logging config could not be read from the .env file or if the subscriber could not be set
    pub fn init(info: LogInfo) {
        let env_filter = EnvFilter::builder()
            .parse(&info.log_config)
            .expect("could not parse logging config");

        let sec_offset = Local::now().offset().local_minus_utc();

        let subscriber = FmtSubscriber::builder()
            .with_env_filter(env_filter)
            .with_timer(OffsetTime::new(
                UtcOffset::from_whole_seconds(sec_offset).expect("valid utc offset"),
                Rfc2822,
            ))
            .pretty()
            .finish();
        tracing::subscriber::set_global_default(subscriber)
            .expect("setting default subscriber failed");

        info!("Using log config `{}`.", info.log_config);

        drop(info); // prevent warning: initialization should take info.

        info!("Using time offset {}.", Local::now().offset().to_string());
    }
}

#[cfg(test)]
mod tests {
    use rusty_fork::rusty_fork_test;

    use super::{LogInfo, Logger};

    // put in separate process to allow setting subscriber to avoid conflict with `traced_test`s
    rusty_fork_test! {
        #[test]
        fn test_logger_init() {
            let info = LogInfo {
                log_config: "trace".into(),
            };
            Logger::init(info);
        }

    }
}
