use crate::interface::image_validation::ImageValidationError::InvalidResponse;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::{SafeSearchJson, SafeSearchResponseJson};
use google_jwt_auth::AuthConfig;
use std::fs;

static API_REST_URL: &str = "https://vision.googleapis.com/v1/images:annotate";
static API_USAGE: &str = "https://www.googleapis.com/auth/cloud-vision";
static PROJECT_ID_HEADER: &str = "x-goog-user-project";
static REQUEST_TYPE: &str = "SAFE_SEARCH_DETECTION";
static CONTENT_TYPE: &str = "application/json";
static TOKEN_LIFETIME: i64 = 3600;
static CHARSET: &str = "utf-8";

/// The [`ApiRequest`] struct is used to send images and
/// requests safe-search results from the api rest interface.
pub struct ApiRequest {
    google_project_id: String,
    auth_config: AuthConfig,
}

impl ApiRequest {
    /// This method is used to create a new instance of the [`ApiRequest`] struct.
    /// # Params
    /// `service_account_json_path`<br>
    /// This param contains the json as string. The data inside the json is used to
    /// establish a connection to the api interface and authenticate the client.<br>
    /// `google_project_id`<br>
    /// This id is needed to verify the client/caller of the request.
    /// The `project_id` can be obtained in the google console.
    /// # Errors
    /// If json could not be read or the authentication struct could not be build, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned [`ApiRequest`] struct.
    pub fn new(service_account_json_path: String, google_project_id: String) -> Result<Self> {
        let json_str = fs::read_to_string(service_account_json_path)?;

        Ok(Self {
            google_project_id,
            auth_config: AuthConfig::build(json_str, String::from(API_USAGE))?,
        })
    }

    /// This method calls the google api with the provided image. After evaluation, the api sends the results back.
    /// These results are provided in a json, which will be returned if nothing went wrong.
    /// # Params
    /// `b64_image`<br>
    /// This param contains the image as string.
    /// # Errors
    /// If the api responded with an error or any connection fault happened, an error will be returned.
    /// See [`crate::interface::image_validation::ImageValidationError`] for more info about the errors.
    /// # Return
    /// The mentioned json ([`SafeSearchJson`]), containing the evaluated values.
    pub async fn encoded_image_validation(&self, b64_image: String) -> Result<SafeSearchJson> {
        let token = self.auth_config.generate_auth_token(TOKEN_LIFETIME).await?;
        let json_resp = self.request_api(b64_image, token).await?.responses.pop();
        match json_resp {
            None => Err(InvalidResponse),
            Some(json) => Ok(json.safeSearchAnnotation),
        }
    }

    async fn request_api(
        &self,
        b64_image: String,
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
            .body(build_request_body(&b64_image))
            .send()
            .await?;
        // TODO retry with error json if response could not be decoded.
        // TODO For now, this decode error (containing the response error json)..
        // TODO ..will be displayed as decode error and not as api error.
        Ok(resp.json::<SafeSearchResponseJson>().await?)
    }
}

fn build_request_body(b64_image: &str) -> String {
    format!(
        r#"{{"requests":[{{"image":{{"content":"{b64_image}"}},"features":[{{"type":"{REQUEST_TYPE}"}},]}}]}}"#
    )
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use crate::layer::data::image_validation::api_request::ApiRequest;

    // Very Small b64 image
    static B64_IMAGE: &str = "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAQMAAAD+wSzIAAAABlBMVEX///+/v7+jQ3Y5AAAADklEQVQI12P4AIX8EAgALgAD/aNpbtEAAAAASUVORK5CYII";
    static JSON_PATH: &str = "src/layer/data/image_validation/test/test-client.json";

    #[tokio::test]
    #[ignore]
    async fn test_generate_auth_token() {
        let api_req = ApiRequest::new(String::from(JSON_PATH), String::from("mensaka")).unwrap();
        let resp = api_req
            .encoded_image_validation(String::from(B64_IMAGE))
            .await;
        assert!(resp.is_ok());
        println!("{resp:?}");
    }

    // Tests are only possible if we get the client.json hidden in the ci
}
