use tracing_subscriber::{EnvFilter, FmtSubscriber};

/// Struct containing all configurations available for the logging system.
pub struct LogInfo {
    /// Logging specifier following the schema of [https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html]
    pub log_config: String,
}

/// Class for initializing the logging.
pub struct Logger;

impl Logger {
    // Initializes the logger.
    pub fn init(info: LogInfo) {
        let env_filter = EnvFilter::builder()
            .parse(info.log_config)
            .expect("could not parse logging config");

        let subscriber = FmtSubscriber::builder()
            .with_env_filter(env_filter)
            .pretty()
            .finish();
        tracing::subscriber::set_global_default(subscriber)
            .expect("setting default subscriber failed");
    }
}

#[cfg(test)]
mod tests {
    use super::{LogInfo, Logger};

    #[test]
    fn test_logger_init() {
        let info = LogInfo {
            log_config: "trace".into(),
        };
        Logger::init(info);
    }
}
