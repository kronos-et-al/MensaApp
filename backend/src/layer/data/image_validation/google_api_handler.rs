use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
use crate::interface::image_validation::Result;
use crate::util::ImageResource;
use async_trait::async_trait;
use crate::layer::data::image_validation::api_request::ApiRequest;
use crate::layer::data::image_validation::image_evaluation::ImageEvaluation;

//todo
pub struct GoogleApiHandler {
    evaluation: ImageEvaluation,
    request: ApiRequest,
}

impl GoogleApiHandler {
    pub fn new(info: ImageValidationInfo) -> Self {
        Self {
            evaluation: ImageEvaluation::new(info.acceptance),
            request: ApiRequest::new(info.google_api_key),
        }
    }
}

#[async_trait]
impl ImageValidation for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        todo!()
    }
}
