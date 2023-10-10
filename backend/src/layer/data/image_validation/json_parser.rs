use crate::interface::image_validation::{ImageValidationError, Result};
use crate::layer::data::image_validation::json_structs::{EncodedRequestJson, SafeSearchResponseJson};

pub fn create_json_request() -> Result<EncodedRequestJson> {
    todo!()
}

pub fn parse_valid_response() -> Result<SafeSearchResponseJson> {
    todo!()
}

fn parse_error_response() -> ImageValidationError {
    todo!()
}
