use axum::body::Bytes;
use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::ImageHosterError;
use crate::layer::data::flickr_api::json_parser::JsonParser;
use reqwest::Response;
use tracing::debug;

pub struct ApiRequest {
    api_key: String,
}

const BASE_URL: &str = "https://api.flickr.com/services/rest/?method=";
const GET_SIZES: &str = "flickr.photos.getSizes";
const GET_LICENCE_HISTORY: &str = "flickr.photos.licenses.getLicenseHistory";

const TAG_API_KEY: &str = "&api_key=";
const TAG_PHOTO_ID: &str = "&photo_id=";
const FORMAT: &str = "&format=json&nojsoncallback=1";

impl ApiRequest {
    /// Creates an instance of an [`ApiRequest`].
    #[must_use]
    pub const fn new(api_key: String) -> Self {
        Self { api_key }
    }

    async fn request_url(&self, url: &String) -> Result<Response, ImageHosterError> {
        let res = reqwest::get(url)
            .await
            .map_err(|e| ImageHosterError::NotConnected(e.to_string()))?;
        debug!("request_url finished with response: {:?}", res);
        Ok(res)
    }

    /// This method is used to request image information for the given `photo_id` from the flickr api.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// Another request, which expects an error will be attempted.
    /// This error request returns a more detailed error information.
    /// # Returns
    /// An Error (as above mentioned) or an [`ImageMetaData`] struct containing information about the requested image.
    pub async fn flickr_photos_get_sizes(
        &self,
        photo_id: &str,
    ) -> Result<ImageMetaData, ImageHosterError> {
        let url = &format!(
            "{BASE_URL}{GET_SIZES}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{FORMAT}",
            api_key = self.api_key,
        );
        let bytes = self.request_url(url).await?.bytes().await?;
        match serde_json::from_slice(&bytes) {
            Ok(root) => JsonParser::parse_get_sizes(root, photo_id),
            Err(_) => Err(self.determine_error(&bytes).await)
        }
    }

    /// This method is used to request image license information for the given `photo_id` from the flickr api.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// Another request, which expects an error will be attempted.
    /// This error request returns a more detailed error information.
    /// # Returns
    /// An Error (as above mentioned).
    /// True if the given image is hosted under a valid license.
    /// False if not.
    pub async fn flickr_photos_license_check(
        &self,
        photo_id: &str,
    ) -> Result<bool, ImageHosterError> {
        let url = &format!(
            "{BASE_URL}{GET_LICENCE_HISTORY}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{FORMAT}",
            api_key = self.api_key
        );
        let bytes = self.request_url(url).await?.bytes().await?;
        match serde_json::from_slice(&bytes) {
            Ok(root) => Ok(JsonParser::check_license(root)),
            Err(_) => Err(self.determine_error(&bytes).await)
        }
    }


    async fn determine_error(&self, bytes: &Bytes) -> ImageHosterError {
        match serde_json::from_slice(bytes) {
            Ok(root) => JsonParser::parse_error(&root),
            Err(e) => ImageHosterError::JsonDecodeFailed(e.to_string()),
        }
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::api_request::ApiRequest;
    use dotenvy::dotenv;
    use std::env;

    fn get_api_key() -> String {
        dotenv().ok();
        env::var("FLICKR_API_KEY").expect("FLICKR_API_KEY should be set in the .env!")
    }

    fn get_api_request() -> ApiRequest {
        ApiRequest {
            api_key: get_api_key(),
        }
    }

    #[tokio::test]
    async fn test_valid_request_sizes() {
        let expected = "https://live.staticflickr.com/65535/53066073286_9fcebfc95f_b.jpg";
        let res = get_api_request()
            .flickr_photos_get_sizes("2oRguN3")
            .await
            .unwrap();
        assert_eq!(expected, res.image_url);
    }

    #[tokio::test]
    async fn test_invalid_request_sizes() {
        let res = get_api_request()
            .flickr_photos_get_sizes("If it is it, it is it; if it is it is it, it is")
            .await;
        assert!(res.is_err());
    }

    #[tokio::test]
    async fn test_valid_error_request() {
        let expected = ImageHosterError::PhotoNotFound;
        let res = get_api_request().flickr_photos_get_sizes("42").await;
        assert_eq!(expected, res.unwrap_err());
    }

    #[tokio::test]
    async fn test_invalid_license_request() {
        let res = get_api_request()
            .flickr_photos_license_check("If it is it, it is it; if it is it is it, it is")
            .await;
        assert!(res.is_err());
    }

    #[tokio::test]
    async fn test_valid_check_license_request() {
        let res = get_api_request()
            .flickr_photos_license_check("52310534489")
            .await
            .unwrap();
        assert!(!res);
    }

    #[tokio::test]
    async fn test_error_check_license_invalid_photo() {
        // FlickrApi responses with code 0 but documents code 1...
        // Only the flickr.photos.licenses.getLicenseHistory request has this issue.
        // See: https://www.flickr.com/services/api/flickr.photos.licenses.getLicenseHistory.html
        // To let this test pass, we use ImageHosterError::ServiceUnavailable even if ImageHosterError::PhotoNotFound is the right one.
        let expected = ImageHosterError::PhotoNotFound;
        let res = get_api_request().flickr_photos_license_check("42").await;
        let err =
            res.expect_err("error_check_license_invalid_photo test failed as res isn't an error");
        assert_eq!(expected, err);
    }
}
