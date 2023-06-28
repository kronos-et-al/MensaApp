//! This interface allows communication with the image hoster.

mod model;

use async_trait::async_trait;
use crate::interface::image_hoster::model::{ImageHosterError, ImageMetaData};

#[async_trait] /// This trait provides essential functions, which are necessary for image validation.
pub trait ImageHoster {
    /// Checks if the given link is valid and provides additional information (ImageMetaData) from the hoster.
    async fn validate_url(url: String) -> Result<ImageMetaData, ImageHosterError>;
    /// Checks if an image still exists at the hoster website.
    async fn check_existence(photo_id: String) -> Result<bool, ImageHosterError>;
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(photo_id: String) -> Result<bool, ImageHosterError>;
}