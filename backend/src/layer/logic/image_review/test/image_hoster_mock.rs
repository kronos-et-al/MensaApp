use std::sync::{Arc, Mutex};

use async_trait::async_trait;

use crate::interface::image_hoster::{model::ImageMetaData, ImageHoster, ImageHosterError, Result};

pub const IMAGE_ID_TO_FAIL_CHECK_EXISTENCE: &str =
    "this image should throw an error, when checked for existence";
pub const IMAGE_ID_THAT_DOES_NOT_EXIST: &str = "this image should not exist";

#[derive(Default)]
pub struct ImageHosterMock {
    existence_calls: Arc<Mutex<u32>>,
}

impl ImageHosterMock {
    #[must_use]
    pub fn get_existence_calls(&self) -> u32 {
        *self
            .existence_calls
            .lock()
            .expect("failed to lock mutex for `existence_calls` counter")
    }
}

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
    async fn check_existence(&self, photo_id: &str) -> Result<bool> {
        *self
            .existence_calls
            .lock()
            .expect("failed to lock mutex for `existence_calls` counter") += 1;
        if photo_id == IMAGE_ID_TO_FAIL_CHECK_EXISTENCE {
            Err(ImageHosterError::PhotoNotFound)
        } else if photo_id == IMAGE_ID_THAT_DOES_NOT_EXIST {
            Ok(false)
        } else {
            Ok(true)
        }
    }
    /// Checks whether the licence is acceptable for our purposes.
    async fn check_licence(&self, _photo_id: &str) -> Result<bool> {
        Ok(true)
    }
}
