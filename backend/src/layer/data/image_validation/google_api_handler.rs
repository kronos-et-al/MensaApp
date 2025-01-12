use crate::interface::image_validation::ImageValidationError::ImageEncodeFailed;
use crate::interface::image_validation::Result;
use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
use crate::layer::data::image_validation::api_request::ApiRequest;
use crate::layer::data::image_validation::image_evaluation::ImageEvaluation;
use crate::util::ImageResource;
use async_trait::async_trait;
use base64::engine::general_purpose;
use base64::Engine;
use image::ImageFormat;
use std::io::Cursor;

/// The [`GoogleApiHandler`] struct is used to manage tasks
/// of the [`crate::layer::data::image_validation`] component.
///
/// The tasks are:<br>
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
            request: ApiRequest::new(&info.service_account_info, info.project_id)?,
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
    img.write_to(&mut Cursor::new(&mut image_data), ImageFormat::Png)
        .map_err(|e| ImageEncodeFailed(e.to_string()))?;
    Ok(general_purpose::STANDARD.encode(image_data))
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
    use crate::layer::data::image_validation::google_api_handler::{
        image_to_base64, GoogleApiHandler,
    };
    use base64::prelude::BASE64_STANDARD;
    use base64::Engine;
    use dotenvy::dotenv;
    use std::{env, fs};

    const J_IMG: &str = "src/layer/data/image_validation/test/test.jpg";
    const P_IMG: &str = "src/layer/data/image_validation/test/test.png";

    #[tokio::test]
    async fn test_validate_image() {
        let handler = get_handler();
        let image = image::open(P_IMG).unwrap();
        let res = handler.validate_image(&image).await;
        assert!(res.is_ok());
    }

    #[test]
    fn test_image_to_base64() {
        let j_img = image::open(J_IMG).unwrap();
        let p_img = image::open(P_IMG).unwrap();
        assert_eq!(
            j_img,
            image::load_from_memory(
                &BASE64_STANDARD
                    .decode(image_to_base64(&j_img).unwrap())
                    .unwrap()
            )
            .unwrap()
        );
        assert_eq!(
            p_img,
            image::load_from_memory(
                &BASE64_STANDARD
                    .decode(image_to_base64(&p_img).unwrap())
                    .unwrap()
            )
            .unwrap()
        );
    }

    fn load_b64str(path: &str) -> String {
        fs::read_to_string(path).unwrap()
    }

    fn get_handler() -> GoogleApiHandler {
        dotenv().ok();
        let path = env::var("SERVICE_ACCOUNT_JSON").unwrap();
        let id = env::var("GOOGLE_PROJECT_ID").unwrap();
        let json = fs::read_to_string(path).unwrap();
        GoogleApiHandler::new(ImageValidationInfo {
            acceptance: [1, 1, 1, 1, 1],
            service_account_info: json,
            project_id: id,
        })
        .unwrap()
    }
}
