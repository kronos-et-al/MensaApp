use crate::interface::image_validation::ImageValidationError::InvalidResponse;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::safe_search_validation::json_request::{
    SafeSearchJson, SafeSearchResponseJson,
};
use google_jwt_auth::usage::Usage::CloudVision;
use google_jwt_auth::AuthConfig;
use json::JsonValue;

const API_REST_URL: &str = "https://vision.googleapis.com/v1/images:annotate";
const PROJECT_ID_HEADER: &str = "x-goog-user-project";
const REQUEST_TYPE: &str = "SAFE_SEARCH_DETECTION";
const CONTENT_TYPE: &str = "application/json";
const TOKEN_LIFETIME: i64 = 30;
const CHARSET: &str = "utf-8";

/// The [`SafeSearchRequest`] struct is used to send images and
/// requests safe-search results from the Google safe-search api.
pub struct SafeSearchRequest {
    google_project_id: String,
    auth_config: AuthConfig,
}

impl SafeSearchRequest {
    /// This method is used to create a new instance of the [`SafeSearchRequest`] struct.
    /// # Params
    /// `service_account_json_path`<br>
    /// This param contains the json as string. The data inside the json is used to
    /// establish a connection to the api interface and authenticate the client.<br>
    /// `google_project_id`<br>
    /// This id is needed to verify the client/caller of the request.
    /// The `project_id` can be obtained in the Google console.
    /// # Errors
    /// If json could not be read or the authentication struct could not be build, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`SafeSearchRequest`] struct.
    pub fn new(service_account_info: &str, google_project_id: String) -> Result<Self> {
        Ok(Self {
            google_project_id,
            auth_config: AuthConfig::build(service_account_info, &CloudVision)?,
        })
    }

    /// This method calls the Google api with the provided image. After evaluation, the api sends the results back.
    /// These results are provided in a json, which will be returned if nothing went wrong.
    /// # Params
    /// `b64_image`<br>
    /// This param contains the image as string.
    /// # Errors
    /// If the api responded with an error or any connection fault happened, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned json ([`SafeSearchJson`]), containing the evaluated values.
    pub async fn encoded_image_validation(&self, b64_image: &str) -> Result<SafeSearchJson> {
        let token = self.auth_config.generate_auth_token(TOKEN_LIFETIME).await?;
        let json_resp = self.request_api(b64_image, token).await?.responses.pop();
        match json_resp {
            None => Err(InvalidResponse),
            Some(json) => Ok(json.safeSearchAnnotation),
        }
    }

    async fn request_api(
        &self,
        b64_image: &str,
        auth_token: String,
    ) -> Result<SafeSearchResponseJson> {
        let resp = reqwest::Client::new()
            .post(API_REST_URL)
            .header(
                reqwest::header::AUTHORIZATION,
                format!("Bearer {auth_token}"),
            )
            .header(PROJECT_ID_HEADER, &self.google_project_id)
            .header(reqwest::header::CONTENT_TYPE, CONTENT_TYPE)
            .header(reqwest::header::ACCEPT_CHARSET, CHARSET)
            .body(build_request_body(b64_image).to_string())
            // JsonValue cannot be serialised by serde as it does not implement serialise...
            .send()
            .await?;
        // TODO retry with error json if response could not be decoded.
        // TODO For now, this decode error (containing the response error json)..
        // TODO ..will be displayed as decode error and not as api error.
        Ok(resp.json::<SafeSearchResponseJson>().await?)
    }
}

/// ```json
///     {
///         "requests": [{
///             "image": {
///                 "content":"image as base64",
///             },
///             "features": [{
///                 "type":"SAFE_SEARCH_DETECTION",
///             }]
///         }]
///     }
/// ```
fn build_request_body(b64_image: &str) -> JsonValue {
    json::object! {
        requests: [{
            image: {
                content: b64_image,
            },
            features: [{
                "type": REQUEST_TYPE,
            }]
        }]
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use crate::layer::data::image_validation::safe_search_validation::safe_search_request::SafeSearchRequest;
    use crate::layer::data::image_validation::safe_search_validation::safe_search_request::{
        build_request_body, REQUEST_TYPE,
    };
    use dotenvy::dotenv;
    use std::{env, fs};

    // Very Small b64 image
    const B64_IMAGE: &str = "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII";

    #[test]
    fn text_build_request_body() {
        let json_string = format!(
            r#"{{"requests":[{{"image":{{"content":"{B64_IMAGE}"}},"features":[{{"type":"{REQUEST_TYPE}"}}]}}]}}"#
        );
        let parsed = json::parse(json_string.as_str()).unwrap();
        let json = build_request_body(B64_IMAGE);

        assert_eq!(json_string, json.to_string());
        assert_eq!(json, parsed);
    }

    #[tokio::test]
    async fn test_encoded_image_validation() {
        dotenv().ok();
        let path = env::var("SERVICE_ACCOUNT_JSON").unwrap();
        let id = env::var("GOOGLE_PROJECT_ID").unwrap();
        let json = fs::read_to_string(path).unwrap();
        let api_req = SafeSearchRequest::new(&json, id).unwrap();
        let resp = api_req.encoded_image_validation(B64_IMAGE).await;
        assert!(resp.is_ok());
    }
}
