use crate::interface::image_validation::ImageValidation;
use crate::interface::image_validation::Result;
use crate::util::ImageResource;
use async_trait::async_trait;

pub struct GoogleApiHandler {
    acceptance: [u8; 5],
    google_api_key: String,
}

impl GoogleApiHandler {
    const fn new(acceptance: [u8; 5], google_api_key: String) -> Self {
        Self {
            acceptance,
            google_api_key
        }
    }
}

#[async_trait]
impl ImageValidation for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        todo!()
    }
}
