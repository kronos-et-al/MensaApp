//! This interface allows to validate the content of an image.

use crate::util::ImageResource;
use std::io;

use async_trait::async_trait;
use thiserror::Error;

/// Result returned from image validation operations, potentially containing a [`ImageValidationError`].
pub type Result<T> = std::result::Result<T, ImageValidationError>;

/// This interface allows to interact with the underlying image api.
/// For now, this interface only verifies an image by checking whether it does contain inappropriate content.
#[async_trait]
pub trait ImageValidation: Send + Sync {
    /// Validates if an image does not contain any inappropriate (explicit, etc.) content.
    async fn validate_image(&self, image: &ImageResource) -> Result<()>;
}

/// Enum describing possible ways an image validation can go wrong
#[derive(Debug, Error)]
pub enum ImageValidationError {
    /// Error returned when an image contains invalid content.
    #[error("This image contains {0} content. Detected level: {1}. Maximum level allowed: {2}.")]
    InvalidContent(String, u8, u8),
    /// Error returned when the response json could not be returned.
    #[error("The api response json could not be decoded. Image validation failed.")]
    JsonDecodeFailed,
    /// The response evaluation is empty.
    #[error("The api responded with no values.")]
    InvalidResponse,
    /// Error returned when the api request fails.
    #[error("The provided rest request, could not be send. Image validation failed.")]
    RestRequestFailed,
    /// Image could not be decoded
    #[error("The provided image could not be decoded to base64: {0}")]
    ImageEncodeFailed(String),
    /// The Image contains invalid content
    #[error("The provided image does contain invalid content: {0}")]
    ImageInvalid(String),
    /// An api related error. Returns the error provided by the api.
    #[error("The api responded with error '{0}'.")]
    ApiResponseError(String),
    /// Something during the token generation went wrong.
    #[error("An error occurred during the token generation: {0}")]
    TokenGenerationError(#[from] google_jwt_auth::error::TokenGenerationError),
    /// Some reqwest error occurred.
    #[error("Some error during an request occurred: {0}")]
    ReqwestError(#[from] reqwest::Error),
    /// The json file could not be read.
    #[error("The json file could not be read: {0}")]
    FileReaderError(#[from] io::Error),
}

/// Structure that contains all information necessary for the image validation component.
#[derive(Default)]
pub struct ImageValidationInfo {
    /// See [`SafeSearchInfo`]
    pub safe_search_info: Option<SafeSearchInfo>,
    /// See [`GeminiInfo`]
    pub gemini_info: Option<GeminiInfo>,
}

/// This struct contains all safe search api related info.
/// See each entry for more information.
pub struct SafeSearchInfo {
    /// Five numbers from 0 to 5 to set each level of a category.
    pub acceptance: [u8; 5],
    /// This information is needed to request authentication tokens.
    pub service_account_info: String,
    /// This project identifier is needed to call image api functions.
    pub project_id: String,
}

/// This struct contains all gemini api related info.
/// See each entry for more information.
pub struct GeminiInfo {
    /// This api key is needed for gemini api requests.
    pub gemini_api_key: String,
    /// This string contains the question, that gemini answers for each image validation
    pub gemini_text_request: String,
}
