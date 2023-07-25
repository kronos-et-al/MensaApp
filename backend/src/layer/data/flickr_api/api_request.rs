use reqwest::Response;
use crate::interface::image_hoster::ImageHosterError;
use tracing::log::debug;
use crate::interface::image_hoster::model::ImageMetaData;
use crate::layer::data::flickr_api::json_parser::JsonParser;
use crate::layer::data::flickr_api::json_structs::{JsonRootError, JsonRootLicense, JsonRootSizes};

pub struct ApiRequest {
    api_key: String
}

const BASE_URL: &str = "https://api.flickr.com/services/rest/?method=";
const GET_SIZES: &str = "flickr.photos.getSizes";
const GET_LICENCE_HISTORY: &str = "flickr.photos.licenses.getLicenseHistory";

const TAG_API_KEY: &str = "&api_key=";
const TAG_PHOTO_ID: &str = "&photo_id=";
const FORMAT: &str = "&format=json&nojsoncallback=1";


impl ApiRequest {
    /// Creates an instance of an [`ApiRequest`].
    pub const fn new(api_key: String) -> Self {
        Self {
            api_key
        }
    }

    async fn request_url(&self, url: &String) -> Result<Response, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?;
        debug!("request_url finished with response: {:?}", res);
        Ok(res)
    }

    /// # Return
    /// The [`JsonRootSizes`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_sizes(&self, url: &String) -> Result<JsonRootSizes, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootSizes>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_sizes finished: {:?}", root);
        Ok(root)
    }

    /// # Return
    /// The [`JsonRootLicense`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_license(&self, url: &String) -> Result<JsonRootLicense, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootLicense>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_license finished: {:?}", root);
        Ok(root)
    }

    /// # Return
    /// The [`JsonRootError`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_err(&self, url: &String) -> Result<JsonRootError, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootError>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_err finished: {:?}", root);
        Ok(root)
    }

    /// This method creates an url for an api get_sizes request.
    /// This url is used to create an rest request.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// Another request, which expects an error 'll be attempted.
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
        match self.request_sizes(url).await {
            Ok(sizes) => Ok(JsonParser::parse_get_sizes(sizes, photo_id)?),
            Err(e) => Err(self.determine_error(url, e).await)
        }
    }

    /// This method creates an url for an api get_licenses request.
    /// This url is used to create an rest request.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// Another request, which expects an error 'll be attempted.
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
        match self.request_license(url).await {
            Ok(licenses) => Ok(JsonParser::check_license(licenses)),
            Err(e) => Err(self.determine_error(url, e).await)
        }
    }

    /// This method requests the flickr api and expects an error response.
    /// # Returns
    /// The hoster error as an [`ImageHosterError`].
    async fn determine_error(&self, url: &String, e: ImageHosterError) -> ImageHosterError {
        // TODO .map
        if e != ImageHosterError::DecodeFailed {
            return e;
        }

        match self.request_url(url).await {
                Ok(res) => {
                    let error_root = match res.json::<JsonRootError>().await.map_err(|_| ImageHosterError::DecodeFailed) {
                        Ok(root) => root,
                        Err(e) => return e
                    };
                    JsonParser::parse_error(&error_root)
                }
                Err(e) => e
        }
    }
}

#[cfg(test)]
mod test {
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::api_request::ApiRequest;
    use crate::layer::data::flickr_api::json_structs::*;
    use crate::layer::data::flickr_api::test::const_test_data::{get_api_key, get_licenses_url, get_sizes_url};

    fn get_api_request() -> ApiRequest {
        ApiRequest {
            api_key: get_api_key()
        }
    }

    #[tokio::test]
    async fn valid_request_sizes() {
        let expected = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: "Square".to_string(),
                        width: 75,
                        height: 75,
                        source: "https://live.staticflickr.com/65535/53066073286_9fcebfc95f_s.jpg".to_string(),
                    }
                ],
            },
        };
        let res = get_api_request().request_sizes(&get_sizes_url(String::from("2oRguN3"))).await.unwrap();
        assert_eq!(expected.sizes.size.first().unwrap().label, res.sizes.size.first().unwrap().label);
        assert_eq!(expected.sizes.size.first().unwrap().source, res.sizes.size.first().unwrap().source);
    }

    #[tokio::test]
    async fn invalid_request_sizes() {
        let expected = ImageHosterError::NotConnected;
        let res = get_api_request().request_sizes(&String::from("If it is it, it is it; if it is it is it, it is")).await;
        assert_eq!(expected, res.expect_err("invalid_request_sizes test failed as res isn't an error"));
    }

    #[tokio::test]
    async fn valid_error_request() {
        let expected = JsonRootError {
            stat: String::from("fail"),
            code: 1,
            message: String::from("Photo not found"),
        };
        let res = get_api_request().request_err(&get_sizes_url(String::from("42"))).await.unwrap();
        assert_eq!(expected.code, res.code);
        assert_eq!(expected.message, res.message);
    }

    #[tokio::test]
    async fn invalid_license_request() {
        let expected = ImageHosterError::NotConnected;
        let res = get_api_request().request_license(&String::from("If it is it, it is it; if it is it is it, it is")).await;
        assert_eq!(expected, res.expect_err("invalid_license_request test failed as res isn't an error"));
    }

    #[tokio::test]
    async fn valid_check_license_request() {
        let expected = JsonRootLicense {
                license_history: vec![
                    LicenceHistory {
                        date_change: 1_661_436_555,
                        old_license: "All Rights Reserved".to_string(),
                        new_license: String::new(),
                    }
                ]
        };
        let res = get_api_request().request_license(&get_licenses_url(String::from("52310534489"))).await;
        let license_history = res.unwrap().license_history.first().unwrap().clone();
        assert_eq!(expected.license_history.first().unwrap().old_license, license_history.old_license);
        assert_eq!(expected.license_history.first().unwrap().date_change, license_history.date_change);
        assert_eq!(expected.license_history.first().unwrap().new_license, license_history.new_license);
    }

    #[tokio::test]
    async fn error_check_license_invalid_photo() {
        // FlickrApi responses with code 0 but documents code 1...
        // Only the flickr.photos.licenses.getLicenseHistory request has this issue.
        // See: https://www.flickr.com/services/api/flickr.photos.licenses.getLicenseHistory.html
        // To let this test pass, we use ImageHosterError::ServiceUnavailable even if ImageHosterError::PhotoNotFound is the right one.
        let expected = ImageHosterError::ServiceUnavailable;
        let res = get_api_request().flickr_photos_license_check("42").await;
        let err = res.expect_err("error_check_license_invalid_photo test failed as res isn't an error");
        assert_eq!(expected, err);
    }
}
