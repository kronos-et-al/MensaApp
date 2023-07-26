use tracing::Level;
use tracing_subscriber::EnvFilter;

/// Class for initializing the logging.
pub struct Logger;

impl Logger {
    // Initializes the logger.
    pub fn init() {
        let subscriber = tracing_subscriber::FmtSubscriber::builder()
            .with_max_level(Level::TRACE)
            .with_env_filter(
                EnvFilter::builder()
                    .with_env_var("LOG_LEVEL")
                    .from_env()
                    .unwrap(),
            )
            .finish();
        tracing::subscriber::set_global_default(subscriber)
            .expect("Setting default subscriber failed");
    }
}
