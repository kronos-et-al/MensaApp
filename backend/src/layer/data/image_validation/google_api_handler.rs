use crate::interface::image_validation::ImageValidationError::ImageEncodeFailed;
use crate::interface::image_validation::Result;
use crate::interface::image_validation::{ImageValidation, ImageValidationInfo};
use crate::layer::data::image_validation::gemini_validation::gemini_evaluation::GeminiEvaluation;
use crate::layer::data::image_validation::gemini_validation::gemini_request::GeminiRequest;
use crate::layer::data::image_validation::safe_search_validation::safe_search_evaluation::SafeSearchEvaluation;
use crate::layer::data::image_validation::safe_search_validation::safe_search_request::SafeSearchRequest;
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
#[derive(Default)]
pub struct GoogleApiHandler {
    safe_search_handler: Option<SafeSearchHandler>,
    gemini_handler: Option<GeminiHandler>,
}

struct SafeSearchHandler {
    evaluation: SafeSearchEvaluation,
    request: SafeSearchRequest,
}

struct GeminiHandler {
    evaluation: GeminiEvaluation,
    request: GeminiRequest,
}

impl GoogleApiHandler {
    /// This method creates a new instance of the [`GoogleApiHandler`].
    /// # Params
    /// `info`<br>
    /// This struct contains all information :) that is needed to set up this struct like
    /// authentication information and acceptance level for the image evaluation.
    /// # Errors
    /// It is possible that the [`ApiRequest`] creation fails, as the provided information causes failures.
    /// These failures will be returned as an error.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`GoogleApiHandler`] struct.
    pub fn new(info: ImageValidationInfo) -> Result<Self> {
        let mut handler = GoogleApiHandler::default();
        if let Some(info) = info.safe_search_info {
            handler.safe_search_handler = Some(SafeSearchHandler {
                evaluation: SafeSearchEvaluation::new(info.acceptance),
                request: SafeSearchRequest::new(&info.service_account_info, info.project_id)?,
            });
        }
        if let Some(info) = info.gemini_info {
            handler.gemini_handler = Some(GeminiHandler {
                evaluation: GeminiEvaluation::default(),
                request: GeminiRequest::new(
                    info.gemini_api_key,
                    &info.gemini_text_request,
                ),
            });
        }
        Ok(handler)
    }
}

#[async_trait]
impl ImageValidation for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        let mut safe_search_result = Ok(());
        let mut gemini_result = Ok(());
        let b64_image = image_to_base64(image)?;
        
        if let Some(handler) = self.safe_search_handler.as_ref() {
            let results = handler.request.encoded_image_validation(&b64_image).await?;
            safe_search_result = handler.evaluation.verify(&results);
        }
        if let Some(handler) = self.gemini_handler.as_ref() {
            let results = handler.request.encoded_image_validation(&b64_image).await?;
            gemini_result = handler.evaluation.evaluate(&results);
        }
        if safe_search_result.is_ok() && gemini_result.is_ok() {
            Ok(())
        } else if safe_search_result.is_err() {
            safe_search_result
        } else {
            gemini_result
        }
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

    use crate::interface::image_validation::{GeminiInfo, ImageValidation, ImageValidationInfo, SafeSearchInfo};
    use crate::layer::data::image_validation::google_api_handler::{
        image_to_base64, GoogleApiHandler,
    };
    use base64::prelude::BASE64_STANDARD;
    use base64::Engine;
    use dotenvy::dotenv;
    use std::{env, fs};

    const J_B64_IMG: &str = "src/layer/data/image_validation/test/b64_test.jpg";
    const P_B64_IMG: &str = "src/layer/data/image_validation/test/b64_test.png";
    const VALID_IMG: &str = "src/layer/data/image_validation/test/valid_food.jpg";
    const INVALID_IMG: &str = "src/layer/data/image_validation/test/invalid_food.jpg";

    // These test can fail if gemini decides to deny the valid image.
    // The provided images should be an easy task to decide.
    // Even it is very unusual, it could fail.
    #[tokio::test]
    async fn test_validate_image() {
        assert!(get_handler(true, true).validate_image(&image::open(VALID_IMG).unwrap()).await.is_ok());
        assert!(get_handler(true, true).validate_image(&image::open(INVALID_IMG).unwrap()).await.is_err());
        assert!(get_handler(false, false).validate_image(&image::open(INVALID_IMG).unwrap()).await.is_ok());
        assert!(get_handler(false, true).validate_image(&image::open(INVALID_IMG).unwrap()).await.is_err());
        assert!(get_handler(false, true).validate_image(&image::open(VALID_IMG).unwrap()).await.is_ok());
    }

    #[test]
    fn test_image_to_base64() {
        let j_img = image::open(J_B64_IMG).unwrap();
        let p_img = image::open(P_B64_IMG).unwrap();
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

    fn get_handler(use_safe_search: bool, use_gemini: bool) -> GoogleApiHandler {
        dotenv().ok();
        let path = env::var("SERVICE_ACCOUNT_JSON").unwrap();
        let id = env::var("GOOGLE_PROJECT_ID").unwrap();
        let json = fs::read_to_string(path).unwrap();
        let key = env::var("GEMINI_API_KEY").unwrap();
        let text = env::var("GEMINI_TEXT_REQUEST").unwrap();
        
        let safe_search_info = if use_safe_search { Some(
            SafeSearchInfo { 
                acceptance: [2, 2, 2, 2, 2],
                service_account_info: json,
                project_id: id 
            }
        ) } else { None }; 
        let gemini_info = if use_gemini { Some(
            GeminiInfo {
                gemini_api_key: key,
                gemini_text_request: text
            }
        ) } else { None };
        
        GoogleApiHandler::new(ImageValidationInfo {
            safe_search_info,
            gemini_info,
        }).unwrap()
    }
}
