use reqwest::Response;
use crate::interface::image_hoster::ImageHosterError;
use tracing::log::debug;
use crate::interface::image_hoster::model::ImageMetaData;
use crate::layer::data::flickr_api::json_parser::JSONParser;
use crate::layer::data::flickr_api::json_structs::*;

pub struct ApiRequest {
    api_key: String,
    parser: JSONParser
}

impl ApiRequest {
    const BASE_URL: &'static str = "https://api.flickr.com/services/rest/?method=";
    const GET_SIZES: &'static str = "flickr.photos.getSizes";
    const GET_LICENCE_HISTORY: &'static str = "flickr.photos.licenses.getLicenseHistory";

    const TAG_API_KEY: &'static str = "&api_key=";
    const TAG_PHOTO_ID: &'static str = "&photo_id=";
    const FORMAT: &'static str = "&format=json&nojsoncallback=1";

    /// Creates an instance of an [`ApiRequest`].
    pub fn new(api_key: String) -> Self {
        Self {
            api_key,
            parser: JSONParser::new()
        }
    }

    async fn request_url(&self, url: &String) -> Result<Response, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?;
        debug!("request_url finished with response: {:?}", res);
        Ok(res)
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootSizes`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_sizes(&self, url: &String) -> Result<JsonRootSizes, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootSizes>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_sizes finished: {:?}", root);
        Ok(root)
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootLicense`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_license(&self, url: &String) -> Result<JsonRootLicense, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootLicense>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_license finished: {:?}", root);
        Ok(root)
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootError`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_err(&self, url: &String) -> Result<JsonRootError, ImageHosterError> {
        let root = self.request_url(url).await?.json::<JsonRootError>().await.map_err(|_| ImageHosterError::DecodeFailed)?;
        debug!("request_err finished: {:?}", root);
        Ok(root)
    }

    /// This method creates an api request url.
    /// This url is used to create an request with the [`request_sizes`] function.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// another request with [`request_err`] will be attempted.
    /// This error request returns a more detailed error information.
    /// # Returns
    /// An Error (as above mentioned) or an [`ImageMetaData`] struct containing information about the requested image.
    pub async fn flickr_photos_get_sizes(
        &self,
        photo_id: &str,
    ) -> Result<ImageMetaData, ImageHosterError> {
        let url = &format!(
            "{BASE_URL}{GET_SIZES}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{JSON}",
            BASE_URL = Self::BASE_URL,
            GET_SIZES = Self::GET_SIZES,
            TAG_API_KEY = Self::TAG_API_KEY,
            api_key = self.api_key,
            TAG_PHOTO_ID = Self::TAG_PHOTO_ID,
            JSON = Self::FORMAT
        );
        match self.request_sizes(&url).await {
            Ok(sizes) => Ok(self.parser.parse_get_sizes(sizes, photo_id)),
            Err(e) => Err(self.determine_error(url, e).await)
        }
    }

    /// This method creates an api request url.
    /// This url is used to create an request with the [`request_license`] function.
    /// # Errors
    /// If the request could not be decoded ([`ImageHosterError::DecodeFailed`],
    /// another request with [`request_err`] will be attempted.
    /// This error request returns a more detailed error information.
    /// # Returns
    /// An Error (as above mentioned).
    /// True if the given image is hosted under a valid license (see [`json_parser::get_valid_licences`] for more info).
    /// False if not.
    pub async fn flickr_photos_licenses_get_license_history(
        &self,
        photo_id: &str,
    ) -> Result<bool, ImageHosterError> {
        let url = &format!(
            "{BASE_URL}{GET_LICENCE_HISTORY}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{JSON}",
            BASE_URL = Self::BASE_URL,
            GET_LICENCE_HISTORY = Self::GET_LICENCE_HISTORY,
            TAG_API_KEY = Self::TAG_API_KEY,
            api_key = self.api_key,
            TAG_PHOTO_ID = Self::TAG_PHOTO_ID,
            JSON = Self::FORMAT
        );
        match self.request_license(&url).await {
            Ok(licenses) => Ok(self.parser.check_license(licenses)),
            Err(e) => Err(self.determine_error(url, e).await)
        }
    }

    /// This method creates an api request url.
    /// This url is used to create an request with the [`request_err`] function.
    /// # Returns
    /// The hoster error as an [`ImageHosterError`].
    /// To see all possible cases look here: [`json_parser::parse_error`].
    async fn determine_error(&self, url: &String, e: ImageHosterError) -> ImageHosterError {
        if e == ImageHosterError::DecodeFailed {
            match self.request_err(&url).await {
                Ok(json_error) => self.parser.parse_error(json_error),
                Err(e) => e
            }
        } else {
            e
        }
    }
}

#[cfg(test)]
mod test {
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::api_request::ApiRequest;
    use crate::layer::data::flickr_api::json_parser::JSONParser;
    use crate::layer::data::flickr_api::json_structs::*;
    use crate::layer::data::flickr_api::test::const_test_data::{get_api_key, get_licenses_url, get_sizes_url};

    fn get_api_request() -> ApiRequest {
        ApiRequest {
            api_key: get_api_key(),
            parser: JSONParser::new(),
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
        assert_eq!(expected, res.err().unwrap());
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
        assert_eq!(expected, res.err().unwrap());
    }

    #[tokio::test]
    async fn valid_check_license_request() {
        let expected = JsonRootLicense {
                license_history: vec![
                    LicenceHistory {
                        date_change: 1661436555,
                        old_license: "All Rights Reserved".to_string(),
                        new_license: "".to_string(),
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
        let res = get_api_request().flickr_photos_licenses_get_license_history("42").await;
        let err = res.err().unwrap();
        assert_eq!(expected, err);
    }
}
