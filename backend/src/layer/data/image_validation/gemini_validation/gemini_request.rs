use crate::interface::image_validation::ImageValidationError::InvalidResponse;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::gemini_validation::json_request::GeminiResponseJson;

const API_REST_URL: &str =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";
const REQUEST_TYPE: &str = "image/jpeg";
const CONTENT_TYPE: &str = "application/json";
const REQUEST_SPECIFICATION: &str = "Answer yes or no and give a short explanation in English.";

pub struct GeminiRequest {
    api_key: String,
    text_request: String,
}

impl GeminiRequest {
    pub fn new(api_key: String, text_request: String) -> Self {
        Self {
            api_key,
            text_request: format!(
                "{text_request} {REQUEST_SPECIFICATION}"
            ),
        }
    }

    pub async fn encoded_image_validation(&self, b64_image: String) -> Result<String> {
        let json_resp = self.request_api(b64_image).await?.candidates.pop();
        match json_resp {
            None => Err(InvalidResponse),
            Some(mut json) => match json.content.parts.pop() {
                None => Err(InvalidResponse),
                Some(part) => Ok(part.text),
            },
        }
    }

    async fn request_api(&self, b64_image: String) -> Result<GeminiResponseJson> {
        let resp = reqwest::Client::new()
            .post(format!("{API_REST_URL}?key={key}", key = &self.api_key))
            .header(reqwest::header::CONTENT_TYPE, CONTENT_TYPE)
            .body(build_request_body(&self.text_request, &b64_image))
            .send()
            .await?;
        // TODO retry with error json if response could not be decoded.
        // TODO For now, this decode error (containing the response error json)..
        // TODO ..will be displayed as decode error and not as api error.
        Ok(resp.json::<GeminiResponseJson>().await?)
    }
}

fn build_request_body(text_request: &str, b64_image: &str) -> String {
    format!(
        r#"{{"contents":[{{"parts":[{{"text":"{text_request}"}},{{"inline_data": {{"mime_type":"{REQUEST_TYPE}","data":"{b64_image}"}}}}]}}]}}"#
    )
}
