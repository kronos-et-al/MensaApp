use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use async_trait::async_trait;
use regex::Regex;

#[derive(Debug, Clone)]
pub struct HosterInfo {
    api_key: String
}

pub struct FlickrApiHandler {
    request: ApiRequest
}

impl FlickrApiHandler {
    pub fn new(info: HosterInfo) -> Self {
        Self {
            request: ApiRequest::new(info.api_key),
        }
    }

    const URL_REGEX: &'static str = r"^((http[s]?|ftp):\/)?\/?([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$";

    // URL TYPE 1: https://www.flickr.com/photos/gerdavs/52310534489/ <- remove last '/'
    // URL TYPE 2: https://flic.kr/p/2nGvar4
    // Both cases: Split with '/' and get last member (= photo_id).
    fn determine_photo_id<'a>(&'a self, mut url: &'a str) -> Result<&str, ImageHosterError> {
        let regex = Regex::new(URL_REGEX).expect("regex creation failed");
        // TODO regex match

        if url.ends_with("/") {
            // remove last '/'
            let mut chars = url.chars();
            chars.next_back();
            url = chars.as_str();
        }
        let splits= url.split('/');
        match splits.last() {
            None => Err(ImageHosterError::FormatNotFound(format!("this url format is not supported: '{}'", url))),
            Some(last) => Ok(last)
        }
    }
}

#[async_trait]
impl ImageHoster for FlickrApiHandler {
    /// This method validates an url to an image hosted at flickr.com.
    /// # Errors
    /// If the url can't be compiled an [`ImageHosterError::FormatNotFound`] 'll be returned.<br>
    /// If the connection to flickr couldn't be established [`ImageHosterError::NotConnected`] 'll be returned.<br>
    /// If the flickr api isn't available [`ImageHosterError::ServiceUnavailable`] 'll be returned.<br>
    /// If some response couldn't be decode by this server [`ImageHosterError::DecodeFailed`] 'll be returned.<br>
    /// More error information is described here: [`ImageHosterError`].
    /// # Return
    /// If the image exists, the [`ImageMetaData`] struct 'll be returned.
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData, ImageHosterError> {
        let photo_id = self.determine_photo_id(url)?;
        self.request.flickr_photos_get_sizes(photo_id).await
    }

    /// This method checks if an image hosted at flickr.com still exists.
    /// # Return
    /// True if the image exists. False if not.
    /// # Errors
    /// If errors occur, that not decide weather the image exists or not, they 'll be returned.
    async fn check_existence(&self, photo_id: &str) -> Result<bool, ImageHosterError> {
        let res = self.request.flickr_photos_get_sizes(photo_id).await;
        if res.is_ok() {
            Ok(true)
        } else {
            let error = res.err().expect("res isn't ok, so it's an error");
            if error == ImageHosterError::PhotoNotFound {
                Ok(false)
            } else {
                Err(error)
            }
        }
    }

    /// This method checks if an image hosted at flickr.com has a valid license.
    /// A list of all valid licenses is here: [`json_parser::get_valid_licences`]
    /// # Return
    /// True if the image is published under a valid license. False if not.
    /// # Errors
    /// If any error occurs, it 'll be returned.
    async fn check_licence(&self, photo_id: &str) -> Result<bool, ImageHosterError> {
        self.request.flickr_photos_licenses_get_license_history(photo_id).await
    }
}

#[cfg(test)]
mod test {
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::flickr_api_handler::{FlickrApiHandler, HosterInfo};

    fn get_handler() -> FlickrApiHandler {
        FlickrApiHandler::new(
            HosterInfo {
                api_key: String::new(),
            }
        )
    }

    #[test]
    fn valid_determine_photo_id() {
        let valid_url = "https://www.flickr.com/photos/gerdavs/52310534489/";
        let handler = get_handler();
        let res = handler.determine_photo_id(valid_url).unwrap();
        assert_eq!(res, "52310534489");
    }

    #[test]
    fn empty_determine_photo_id() {
        let valid_url = "";
        let handler = get_handler();
        let res = handler.determine_photo_id(valid_url).err().unwrap();
        assert_eq!(res, ImageHosterError::FormatNotFound(format!("this url format is not supported: '{}'", valid_url)));
    }

    #[test]
    fn invalid_determine_photo_id() {
        let valid_url = "";
        let handler = get_handler();
        let res = handler.determine_photo_id(valid_url).err().unwrap();
        assert_eq!(res, ImageHosterError::FormatNotFound(format!("this url format is not supported: '{}'", valid_url)));
    }
}
