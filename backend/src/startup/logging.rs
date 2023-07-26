use tracing::Level;
use tracing_subscriber::FmtSubscriber;

/// Class for initializing the logging.
pub struct Logger;

impl Logger {
    // Initializes the logger.
    pub fn init() {
        // setup logging
        let subscriber = FmtSubscriber::builder()
            .with_max_level(Level::TRACE)
            .with_writer(std::io::stderr)
            .pretty()
            // .with_env_filter(EnvFilter::default())
            .finish();
        tracing::subscriber::set_global_default(subscriber)
            .expect("setting default subscriber failed");
    }
}
