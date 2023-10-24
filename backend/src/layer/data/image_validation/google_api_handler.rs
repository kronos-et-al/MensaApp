use std::io::Cursor;
use crate::interface::image_validation::Result;
use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
use crate::layer::data::image_validation::api_request::ApiRequest;
use crate::layer::data::image_validation::image_evaluation::ImageEvaluation;
use crate::util::ImageResource;
use async_trait::async_trait;
use image::ImageOutputFormat;

//TODO DOC
pub struct GoogleApiHandler {
    evaluation: ImageEvaluation,
    request: ApiRequest,
}

impl GoogleApiHandler {
    //TODO DOC
    pub fn new(info: ImageValidationInfo) -> Result<Self> {
        Ok(Self {
            evaluation: ImageEvaluation::new(info.acceptance),
            request: ApiRequest::new(info.json_path, info.project_id)?,
        })
    }
}

#[async_trait]
impl ImageValidation for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        let b64_image = image_to_base64(image);
        let results = self.request.encoded_image_validation(b64_image).await?;
        self.evaluation.verify(results)
    }
}

fn image_to_base64(img: &ImageResource) -> String {
    let mut image_data: Vec<u8> = Vec::new();
    img.write_to(&mut Cursor::new(&mut image_data), ImageOutputFormat::Png)
        .unwrap();
    base64::encode(image_data) // TODO depreciated
}
