//! This interface allows to validate the content of an image.

use crate::util::ImageResource;

use async_trait::async_trait;
use thiserror::Error;

/// Result returned from image validation operations, potentially containing a [`ImageError`].
pub type Result<T> = std::result::Result<T, ImageError>;

/// This interface allows to validate an image by checking whether it does contain inappropriate content.
#[async_trait]
pub trait ImageValidation: Send + Sync {
    /// Validates if an image does not contain any inappropriate (explicit, etc.) content.
    async fn validate_image(&self, image: &ImageResource) -> Result<()>;
}

/// Enum describing possible ways an image validation can go wrong
#[derive(Debug, Error)]
pub enum ImageError {
    /// Error returned when an image contains invalid content.
    #[error("This image contains content that is not permitted: {0}")]
    InvalidContent(String),
    // TODO
}
