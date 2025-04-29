//! Module for setting up the logging framework.

use std::time::Duration;

use chrono::Local;
use time::{format_description::well_known::Rfc2822, UtcOffset};
use tracing::info;
use tracing_loki::{url::Url, BackgroundTaskController};
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
pub struct Logger {
    loki_shutdown: Option<BackgroundTaskController>,
}

impl Logger {
    /// Initializes the logger.
    ///
    /// # Panics
    /// if the logging config could not be read from the .env file or if the subscriber could not be set
    #[allow(clippy::cognitive_complexity)] // somehow this has high cognitive complexity...
    pub fn init(info: LogInfo) -> Self {
        // env logger
        let env_layer = Self::get_env_fmt_layer(&info.log_config);
        // grafana loki
        let (loki, loki_shutdown) = Self::get_loki_layer(info.loki_url.as_deref()).unzip();

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

        Self { loki_shutdown }
    }

    /// Shuts down logger. Required when using external logging to Grafana loki, useless otherwise.
    pub async fn shutdown(self) {
        if let Some(s) = self.loki_shutdown {
            tokio::time::sleep(Duration::from_millis(1)).await; // allow for last log messages to be send
            s.shutdown().await;
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

    fn get_loki_layer(
        loki_url: Option<&str>,
    ) -> Option<(tracing_loki::Layer, BackgroundTaskController)> {
        loki_url.map(|loki_url| {
            let loki_url_parsed = Url::parse(loki_url).expect("valid loki url");
            let (loki_layer, controller, task) = tracing_loki::builder()
                .label("service_name", "mensa-ka")
                .expect("label `service_name` not yet set")
                .extra_field("pid", format!("{}", std::process::id()))
                .expect("field `pid` not yet set")
                .build_controller_url(loki_url_parsed)
                .expect("build loki layer and task");

            tokio::spawn(task); // todo graceful shutdown
            (loki_layer, controller)
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
            let _ = Logger::init(info);
        }

    }
}
