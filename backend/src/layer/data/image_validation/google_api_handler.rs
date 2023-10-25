use crate::interface::image_validation::ImageValidationError::ImageEncodeFailed;
use crate::interface::image_validation::Result;
use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
use crate::layer::data::image_validation::api_request::ApiRequest;
use crate::layer::data::image_validation::image_evaluation::ImageEvaluation;
use crate::util::ImageResource;
use async_trait::async_trait;
use image::ImageOutputFormat;
use std::io::Cursor;

/// The [`GoogleApiHandler`] struct is used to manage tasks
/// of the [`crate::layer::data::image_validation`] component.
/// These tasks are:<br>
///     - converting images<br>
///     - calling the api<br>
///     - determine which images are allowed<br>
///     - and returning helpful error messages if an image got not accepted
pub struct GoogleApiHandler {
    evaluation: ImageEvaluation,
    request: ApiRequest,
}

impl GoogleApiHandler {
    /// This method creates a new instance of the [`GoogleApiHandler`].
    /// # Params
    /// `info`<br>
    /// This struct contains all information :) that is needed to setup this struct like
    /// authentication information and acceptance level for the image evaluation.
    /// # Errors
    /// It is possible that the [`ApiRequest`] creation fails, as the provided information causes failures.
    /// These failures will be returned as an error.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`GoogleApiHandler`] struct.
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
        let b64_image = image_to_base64(image)?;
        let results = self.request.encoded_image_validation(b64_image).await?;
        self.evaluation.verify(&results)
    }
}

fn image_to_base64(img: &ImageResource) -> Result<String> {
    let mut image_data: Vec<u8> = Vec::new();
    let _ = img
        .write_to(&mut Cursor::new(&mut image_data), ImageOutputFormat::Png)
        .map_err(|e| ImageEncodeFailed(e.to_string()))?;
    Ok(base64::encode(image_data)) // TODO depreciated
}
