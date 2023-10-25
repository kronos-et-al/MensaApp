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
    img.write_to(&mut Cursor::new(&mut image_data), ImageOutputFormat::Png)
        .map_err(|e| ImageEncodeFailed(e.to_string()))?;
    Ok(base64::encode(image_data)) // TODO depreciated
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use std::fs;
    use crate::layer::data::image_validation::google_api_handler::image_to_base64;

    static E_IMG: &str = "src/layer/data/image_validation/test/einstein.png";
    static E_B64: &str = "src/layer/data/image_validation/test/einstein_b64.txt";
    static B_IMG: &str = "src/layer/data/image_validation/test/bohr.png";
    static B_B64: &str = "src/layer/data/image_validation/test/bohr_b64.txt";
    static O_IMG: &str = "src/layer/data/image_validation/test/oppenheimer.png";
    static O_B64: &str = "src/layer/data/image_validation/test/oppenheimer_b64.txt";
    #[test]
    #[ignore] //TODO fix
    fn test_image_to_base64() {
        let b_img = image::open(B_IMG).unwrap();
        let o_img = image::open(O_IMG).unwrap();
        let e_img = image::open(E_IMG).unwrap();
        assert_eq!(image_to_base64(&b_img).unwrap(), load_b64str(B_B64));
        assert_eq!(image_to_base64(&o_img).unwrap(), load_b64str(O_B64));
        assert_eq!(image_to_base64(&e_img).unwrap(), load_b64str(E_B64));
    }

    fn load_b64str(path: &str) -> String {
        fs::read_to_string(path).unwrap()
    }

}