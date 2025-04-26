//! Module for setting up the logging framework.

use chrono::Local;
use time::{format_description::well_known::Rfc2822, UtcOffset};
use tracing::info;
use tracing_loki::url::Url;
use tracing_subscriber::{
    fmt::time::OffsetTime, layer::SubscriberExt, util::SubscriberInitExt, EnvFilter, Layer,
    Registry,
};

/// Struct containing all configurations available for the logging system.
pub struct LogInfo {
    /// Logging specifier following the schema of <https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html>
    pub log_config: String,
    /// URL to the Grafana Loki instance to send logs to.
    pub loki_url: Option<String>,
}

/// Class for initializing the logging.
pub struct Logger;

impl Logger {
    /// Initializes the logger.
    ///
    /// # Panics
    /// if the logging config could not be read from the .env file or if the subscriber could not be set
    pub fn init(info: LogInfo) {
        // env logger
        let env_layer = Self::get_env_fmt_layer(&info.log_config);
        // graphana loki
        let loki = Self::get_loki_layer(info.loki_url.as_deref());

        tracing_subscriber::registry()
            .with(env_layer)
            .with(loki)
            .init();

        info!("Using local log config `{}`.", info.log_config);
        info!("Using time offset {}.", Local::now().offset().to_string());

        if let Some(loki_url) = info.loki_url {
            info!("Logging to Grafana Loki at `{loki_url}`.",);
        } else {
            info!("Logging to Grafana Loki is disabled.");
        }
    }

    fn get_env_fmt_layer(log_config: &str) -> impl Layer<Registry> {
        let env_filter = EnvFilter::builder()
            .parse(log_config)
            .expect("could not parse logging config");

        let sec_offset = Local::now().offset().local_minus_utc();

        tracing_subscriber::fmt::layer()
            .with_timer(OffsetTime::new(
                UtcOffset::from_whole_seconds(sec_offset).expect("valid utc offset"),
                Rfc2822,
            ))
            .pretty()
            .with_filter(env_filter)
    }

    fn get_loki_layer(loki_url: Option<&str>) -> Option<tracing_loki::Layer> {
        loki_url.map(|loki_url| {
            let loki_url_parsed = Url::parse(loki_url).expect("valid loki url");
            let (loki_layer, task) = tracing_loki::builder()
                // .label("host", "mensa-ka")?
                // .extra_field("pid", format!("{}", process::id()))?
                .build_url(loki_url_parsed)
                .expect("build loki layer and task");

            tokio::spawn(task); // todo graceful shutdown
            loki_layer
        })
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
                loki_url: None,
            };
            Logger::init(info);
        }

    }
}
