//! These structs are used for image hoster data
use std::error::Error;
use thiserror::Error;

/// Struct contains information all necessary information that the image hoster provides.
pub struct ImageMetaData {
    /// The image hoster image identification.
    pub id: String,
    /// The url which short links to the image. Different to the url provided by an user.
    pub image_url: String,
    /// The licence of the image.
    pub licence: String,
}

/// Enum describing the possible ways, a image hoster request can fail.
#[derive(Debug, Error)]
pub enum ImageHosterError {
    /// Photo not found error
    #[error("the photo id passed was not a valid photo id")]
    PhotoNotFound,
    /// Permission denied error
    #[error("the calling user does not have permission to view the photo")]
    PermissionDenied,
    /// Invalid API Key error
    #[error("the api key passed was not valid or has expired")]
    InvalidApiKey,
    /// Service currently unavailable error
    #[error("the requested service is temporarily unavailable")]
    ServiceUnavailable,
    ///  Write operation failed error
    #[error("the requested operation failed due to a temporary issue")]
    WriteFailed,
    /// Format "xxx" not found error
    #[error("the requested response format was not found")]
    FormatNotFound(#[from] Box<dyn Error>),
    /// Method "xxx" not found error
    #[error("the requested method was not found")]
    MethodNotFound,
    /// Invalid envelope error
    #[error("the envelope send in the request could not be parsed")]
    InvalidEnvelope,
    /// Invalid XML Method Call error
    #[error("the xml request document could not be parsed")]
    InvalidMethodCall,
    /// Bad URL found error
    #[error("one or more arguments contained a url that has been used for abuse")]
    BadUrlFound,
}
