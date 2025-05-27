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
    /// It is possible that the [`SafeSearchRequest`] creation fails, as the provided information causes failures.
    /// These failures will be returned as an error.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`GoogleApiHandler`] struct.
    pub fn new(info: ImageValidationInfo) -> Result<Self> {
        Ok(Self {
            safe_search_handler: if let Some(info) = info.safe_search_info {
                Some(SafeSearchHandler {
                    evaluation: SafeSearchEvaluation::new(info.acceptance),
                    request: SafeSearchRequest::new(&info.service_account_info, info.project_id)?,
                })
            } else {
                None
            },
            gemini_handler: if let Some(info) = info.gemini_info {
                Some(GeminiHandler {
                    evaluation: GeminiEvaluation::default(),
                    request: GeminiRequest::new(info.gemini_api_key, &info.gemini_text_request),
                })
            } else {
                None
            },
        })
    }
}

#[async_trait]
impl ImageValidation for GoogleApiHandler {
    async fn validate_image(&self, image: &ImageResource) -> Result<()> {
        let b64_image = image_to_base64(image)?;

        let safe_search_result = match self.safe_search_handler.as_ref() {
            Some(handler) => {
                let results = handler.request.encoded_image_validation(&b64_image).await?;
                handler.evaluation.verify(&results)
            }
            None => Ok(()),
        };

        if safe_search_result.is_ok() {
            match self.gemini_handler.as_ref() {
                Some(handler) => {
                    let results = handler.request.encoded_image_validation(&b64_image).await?;
                    handler.evaluation.evaluate(&results)
                }
                None => Ok(()),
            }
        } else {
            safe_search_result
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

    use crate::interface::image_validation::{
        GeminiInfo, ImageValidation, ImageValidationInfo, SafeSearchInfo,
    };
    use crate::layer::data::image_validation::google_api_handler::{
        image_to_base64, GoogleApiHandler,
    };
    use base64::engine::general_purpose;
    use base64::prelude::BASE64_STANDARD;
    use base64::Engine;
    use dotenvy::dotenv;
    use std::{env, fs};
    use uuid::Uuid;

    const J_B64_IMG: &str = "src/layer/data/image_validation/test/b64_test.jpg";
    const P_B64_IMG: &str = "src/layer/data/image_validation/test/b64_test.png";
    const VALID_IMG: &str = "src/layer/data/image_validation/test/valid_food.jpg";
    const INVALID_IMG: &str = "src/layer/data/image_validation/test/invalid_food.jpg";

    #[derive(Debug, serde::Deserialize)]
    struct SampleSet {
        #[allow(dead_code)]
        name: String,
        #[allow(dead_code)]
        uuid: Uuid,
        url: String,
        #[allow(dead_code)]
        rating: i32,
        admin_rating: i32,
    }
    #[tokio::test]
    #[ignore = "Evaluation can only be run manually."]
    // Consider! Running this test, can influence the api pricing.
    // As the images are provided by the production api, some images could be deleted and this test will fail.
    async fn test_evaluate_images() {
        let mut set: Vec<SampleSet> = vec![];
        let file_data =
            fs::read_to_string("src/layer/data/image_validation/test/image_samples.csv").unwrap();
        let mut rdr = csv::ReaderBuilder::new()
            .delimiter(u8::try_from(';').unwrap())
            .from_reader(file_data.as_bytes());
        for rec in rdr.deserialize() {
            set.push(rec.unwrap());
        }
        dotenv().ok();
        let mut score = 0;
        let mut false_positives = 0;
        let mut false_negatives = 0;
        let sum = set.len();
        let text_request = &env::var("GEMINI_TEXT_REQUEST").unwrap();
        println!("Starting gemini evaluation test with: '{text_request}' and {sum} samples");
        let handler = get_handler(false, true, [0, 0, 0, 0, 0], text_request);
        print!("[");
        for rec in &set {
            print!("#");
            let img_bytes = reqwest::get(&rec.url).await.unwrap().bytes().await.unwrap();
            let b64_img = general_purpose::STANDARD.encode(img_bytes);
            let gemini_req = handler
                .gemini_handler
                .as_ref()
                .unwrap()
                .request
                .encoded_image_validation(&b64_img)
                .await
                .unwrap();
            let admin_decision = rec.admin_rating > 0;
            if gemini_req.starts_with("Yes") == admin_decision {
                score += 1;
            } else if !admin_decision {
                false_positives += 1;
            } else {
                false_negatives += 1;
            }
            print!("-");
        }
        println!("]");
        let rejected = sum - score;
        println!("Correct: {score}/{sum}");
        println!("Correct images rejected: {false_negatives}/{rejected}");
        println!("Incorrect images accepted: {false_positives}/{rejected}");
    }

    // These test can fail if gemini decides to deny the valid image.
    // The provided images should be an easy task to decide.
    // Even it is very unusual, it could fail.
    #[tokio::test]
    async fn test_validate_image() {
        let acceptance = [2, 2, 2, 2, 2];
        assert!(get_handler(true, true, acceptance, &String::default())
            .validate_image(&image::open(VALID_IMG).unwrap())
            .await
            .is_ok());
        assert!(get_handler(true, true, acceptance, &String::default())
            .validate_image(&image::open(INVALID_IMG).unwrap())
            .await
            .is_err());
        assert!(get_handler(false, false, acceptance, &String::default())
            .validate_image(&image::open(INVALID_IMG).unwrap())
            .await
            .is_ok());
        assert!(get_handler(false, true, acceptance, &String::default())
            .validate_image(&image::open(INVALID_IMG).unwrap())
            .await
            .is_err());
        assert!(get_handler(false, true, acceptance, &String::default())
            .validate_image(&image::open(VALID_IMG).unwrap())
            .await
            .is_ok());
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

    fn get_handler(
        use_safe_search: bool,
        use_gemini: bool,
        acceptance: [u8; 5],
        text_request: &str,
    ) -> GoogleApiHandler {
        let safe_search_info = if use_safe_search {
            Some(get_safe_search_info(acceptance))
        } else {
            None
        };
        let gemini_info = if use_gemini {
            Some(get_gemini_info(text_request.to_string()))
        } else {
            None
        };

        GoogleApiHandler::new(ImageValidationInfo {
            safe_search_info,
            gemini_info,
        })
        .unwrap()
    }
    fn get_safe_search_info(acceptance: [u8; 5]) -> SafeSearchInfo {
        dotenv().ok();
        let path = env::var("SERVICE_ACCOUNT_JSON").unwrap();
        let id = env::var("GOOGLE_PROJECT_ID").unwrap();
        let json = fs::read_to_string(path).unwrap();
        SafeSearchInfo {
            acceptance,
            service_account_info: json,
            project_id: id,
        }
    }
    fn get_gemini_info(mut text_request: String) -> GeminiInfo {
        dotenv().ok();
        let key = env::var("GEMINI_API_KEY").unwrap();
        if text_request == String::default() {
            text_request = env::var("GEMINI_TEXT_REQUEST").unwrap();
        }
        GeminiInfo {
            gemini_api_key: key,
            gemini_text_request: text_request,
        }
    }
}
