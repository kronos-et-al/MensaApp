use async_trait::async_trait;

use crate::interface::image_hoster::{model::ImageMetaData, ImageHoster, Result};

pub struct ImageHosterMock;

#[async_trait]
impl ImageHoster for ImageHosterMock {
    /// Checks if the given link is valid and provides additional information (ImageMetaData) from the hoster.
    async fn validate_url(_url: String) -> Result<ImageMetaData> {
        Ok(ImageMetaData {
            id: String::default(),
            image_url: String::default(),
            licence: String::default(),
        })
    }
    /// Checks if an image still exists at the hoster website.
    async fn check_existence(_photo_id: String) -> Result<bool> {
        Ok(true)
    }
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(_photo_id: String) -> Result<bool> {
        Ok(true)
    }
}
