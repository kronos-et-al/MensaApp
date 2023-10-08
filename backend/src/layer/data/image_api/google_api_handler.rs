use crate::interface::image_api::ImageApi;
use crate::interface::image_api::Result;
use crate::util::ImageResource;

pub struct GoogleApiHandler {
    acceptance: [u8; 5],
    google_api_key: String,
}

impl GoogleApiHandler {
    fn new(acceptance: [u8; 5], google_api_key: String) -> Self {
        Self {
            acceptance,
            google_api_key
        }
    }
}

impl ImageApi for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        todo!()
    }
}
