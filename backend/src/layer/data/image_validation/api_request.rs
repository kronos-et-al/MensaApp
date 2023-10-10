use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::SafeSearchResponseJson;

//todo
pub struct ApiRequest {
    google_api_key: String,
    google_project_key: String,
}

impl ApiRequest {

    //todo
    #[must_use]
    pub const fn new(google_api_key: String, google_project_key: String) -> Self {
        Self {
            google_api_key,
            google_project_key,
        }
    }

    //todo
    pub fn encoded_image_validation() -> Result<SafeSearchResponseJson> {
        todo!()
    }
}
