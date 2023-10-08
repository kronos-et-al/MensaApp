//! This interface allows to validate the content of an image.

use crate::util::ImageResource;

use async_trait::async_trait;
use thiserror::Error;

/// Result returned from image validation operations, potentially containing a [`ImageError`].
pub type Result<T> = std::result::Result<T, ImageApiError>;

/// This interface allows to interact with the underlying image api.
/// For now, this interface only verifies an image by checking whether it does contain inappropriate content.
#[async_trait]
pub trait ImageApi: Send + Sync {
    /// Validates if an image does not contain any inappropriate (explicit, etc.) content.
    async fn validate_image(&self, image: &ImageResource) -> Result<()>;
}

/// Enum describing possible ways an image validation can go wrong
#[derive(Debug, Error)]
pub enum ImageApiError {
    /// Error returned when an image contains invalid content.
    #[error("This image contains content that is not permitted: {0}")]
    InvalidContent(String),
    /// Error returned when the response json could not be returned.
    #[error("The api response json could not be decoded. Image validation failed.")]
    JsonDecodeFailed,
    /// Error returned when the api request fails.
    #[error("The provided rest request, could not be send. Image validation failed.")]
    RestRequestFailed,
    /// An api related error. Returns the error provided by the api.
    #[error("The api responded with error '{0}'.")]
    ApiResponseError(String),
}
