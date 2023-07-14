use async_trait::async_trait;

use crate::interface::image_hoster::{model::ImageMetaData, ImageHoster, Result};

pub struct ImageHosterMock;

#[async_trait]
impl ImageHoster for ImageHosterMock {
    /// Checks if the given link is valid and provides additional information (ImageMetaData) from the hoster.
    async fn validate_url(&self, _url: &str) -> Result<ImageMetaData> {
        Ok(ImageMetaData {
            id: String::default(),
            image_url: String::default(),
            licence: String::default(),
        })
    }
    /// Checks if an image still exists at the hoster website.
    async fn check_existence(&self, _photo_id: &str) -> Result<bool> {
        Ok(true)
    }
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(&self, _photo_id: &str) -> Result<bool> {
        Ok(true)
    }
}
