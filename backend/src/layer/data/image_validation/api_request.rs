use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::SafeSearchResponseJson;

pub struct ImageVerification {
    google_api_key: String,
}

impl ImageVerification {
    pub fn new(google_api_key: String) -> Self {
        Self { google_api_key }
    }

    pub fn encoded_image_validation() -> Result<SafeSearchResponseJson> {
        todo!()
    }
}
