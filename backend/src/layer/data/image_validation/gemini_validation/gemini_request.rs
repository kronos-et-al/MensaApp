use crate::interface::image_validation::ImageValidationError::InvalidResponse;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::gemini_validation::json_request::GeminiResponseJson;
use json::JsonValue;

const API_REST_URL: &str =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
const REQUEST_TYPE: &str = "image/jpeg";
const REQUEST_SPECIFICATION: &str = "Answer yes or no and give a short explanation in English.";

/// The [`GeminiRequest`] struct is used to send an images with a question and
/// requests gemini for assessment via rest.
pub struct GeminiRequest {
    api_key: String,
    text_request: String,
}

impl GeminiRequest {
    /// This method is used to create a new instance of the [`GeminiRequest`] struct.
    /// # Params
    /// `api_key`<br>
    /// This param contains the api key as string. The key is used to authenticate the client.<br>
    /// `text_request`<br>
    /// This string contains the question that will be answered by gemini.
    /// # Errors
    /// If the authentication or the connection failed, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`GeminiRequest`] struct.
    #[must_use] pub fn new(api_key: String, text_request: &str) -> Self {
        Self {
            api_key,
            text_request: format!(
                "{text_request} {REQUEST_SPECIFICATION}"
            ),
        }
    }

    /// This method calls the Google Gemini api with the provided image.
    /// The api responds with an [`GeminiResponseJson`] or with an error listed below.
    /// These results are provided in a json, which will be returned if nothing went wrong.
    /// # Params
    /// `b64_image`<br>
    /// This param contains the image as string.
    /// # Errors
    /// If the api responded with an error or any connection fault happened, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The assessment of the Gemini api as string.
    pub async fn encoded_image_validation(&self, b64_image: &str) -> Result<String> {
        let json_resp = self.request_api(b64_image).await?.candidates.pop();
        match json_resp {
            None => Err(InvalidResponse),
            Some(mut json) => match json.content.parts.pop() {
                None => Err(InvalidResponse),
                Some(part) => Ok(part.text),
            },
        }
    }

    async fn request_api(&self, b64_image: &str) -> Result<GeminiResponseJson> {
        let resp = reqwest::Client::new()
            .post(API_REST_URL)
            .query(&[("key", &self.api_key)])
            .body(build_request_body(&self.text_request, b64_image).to_string())
            // JsonValue cannot be serialised by serde as it does not implement serialise...
            .send()
            .await?;
        // TODO retry with error json if response could not be decoded.
        // TODO For now, this decode error (containing the response error json)..
        // TODO ..will be displayed as decode error and not as api error.
        
        Ok(resp.json::<GeminiResponseJson>().await?)
    }
}

/// ```json
///     {
///         "contents": [{
///             "parts": [{
///                 "text":"This is a Question?"   
///             },
///             {
///                 "inline_data": {
///                     "mime_type":"image/jpeg",
///                     "data":"image as base64"
///                 }
///             }]
///         }]
///     }
/// ```
fn build_request_body(text_request: &str, b64_image: &str) -> JsonValue {
    json::object! {
        contents: [{
            parts: [{
                text: text_request,
            },
            {
                inline_data: {
                    mime_type: REQUEST_TYPE,
                    data: b64_image
                }
            }]
        }]
    }
}

mod tests {
    #![allow(clippy::unwrap_used)]

    use std::env;
    use dotenvy::dotenv;
    use crate::layer::data::image_validation::gemini_validation::gemini_request::{GeminiRequest, REQUEST_TYPE};
    use crate::layer::data::image_validation::gemini_validation::gemini_request::build_request_body;

    const B64_IMAGE: &str = "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII";
    
    fn get_valid_gemini_struct() -> GeminiRequest {
        dotenv().ok();
        println!("GEMINI_API_KEY:{val:?}", val = env::var("GEMINI_API_KEY"));
        GeminiRequest::new(
            env::var("GEMINI_API_KEY").unwrap(),
            &env::var("GEMINI_TEXT_REQUEST").unwrap(),
        )
    }
    fn get_invalid_gemini_struct() -> GeminiRequest {
        dotenv().ok();
        GeminiRequest::new(
            String::new(),
            &env::var("GEMINI_TEXT_REQUEST").unwrap(),
        )
    }
    
    #[test]
    fn text_build_request_body() {
        let text_request = "This is a Question?";
        
        let json_string =  format!(
            r#"{{"contents":[{{"parts":[{{"text":"{text_request}"}},{{"inline_data":{{"mime_type":"{REQUEST_TYPE}","data":"{B64_IMAGE}"}}}}]}}]}}"#
        );
        let parsed = json::parse(json_string.as_str()).unwrap();
        let json = build_request_body(text_request, B64_IMAGE);
        
        assert_eq!(json_string, json.to_string());
        assert_eq!(json, parsed);
    }
    
    #[tokio::test]
    async fn test_request_api() {
        let valid = get_valid_gemini_struct().request_api(B64_IMAGE).await;
        let invalid = get_invalid_gemini_struct().request_api(B64_IMAGE).await;
        assert!(valid.is_ok());
        assert!(invalid.is_err());
    }

    #[tokio::test]
    async fn test_encoded_image_validation() {
        let valid = get_valid_gemini_struct().encoded_image_validation(B64_IMAGE).await;
        let invalid = get_invalid_gemini_struct().encoded_image_validation(B64_IMAGE).await;
        assert!(valid.is_ok());
        assert!(valid.unwrap().contains("No"));
        assert!(invalid.is_err());
    }
}