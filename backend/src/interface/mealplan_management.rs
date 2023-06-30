//! This interface allows starting the operations for updating the menu from the the canteen's website.
use async_trait::async_trait;

#[async_trait]
pub trait MensaParseScheduling {
    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals of the current date.
    async fn start_update_parsing();

    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals for the next four weeks.
    async fn start_full_parsing();
}
