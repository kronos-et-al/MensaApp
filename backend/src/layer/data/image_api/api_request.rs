use crate::interface::image_api::Result;
use crate::layer::data::image_api::json_structs::SafeSearchResponseJson;

pub struct ApiRequest {
    google_api_key: String,
}

impl ApiRequest {
    pub fn new(google_api_key: String) -> Self {
        Self { google_api_key }
    }

    pub fn encoded_image_validation() -> Result<SafeSearchResponseJson> {
        todo!()
    }
}
