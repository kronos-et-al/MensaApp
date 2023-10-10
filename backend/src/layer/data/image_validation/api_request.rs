use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::SafeSearchResponseJson;

//todo
pub struct ApiRequest {
    google_api_key: String,
}

impl ApiRequest {

    //todo
    pub fn new(google_api_key: String) -> Self {
        Self { google_api_key }
    }

    //todo
    pub fn encoded_image_validation() -> Result<SafeSearchResponseJson> {
        todo!()
    }
}
