use std::sync::{Arc, Mutex};

use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError, Result};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use async_trait::async_trait;
use lazy_static::lazy_static;
use regex::Regex;

#[derive(Debug)]
pub struct FlickrInfo {
    pub api_key: String,
}

pub struct FlickeApiHandler {
    request: ApiRequest,
}

lazy_static! {
    static ref LONG_URL_REGEX: Regex =
        Regex::new(r"(https://www.flickr.com/photos/)(\w+)/(\d+)([/]{0,1})")
            .expect("regex creation failed");
    static ref SHORT_URL_REGEX: Regex =
        Regex::new(r"(https://flic.kr/p/)([\d\w]+)").expect("regex creation failed");
}

impl FlickeApiHandler {
    #[must_use]
    pub fn new(info: FlickrInfo) -> Self {
        Self {
            request: ApiRequest::new(info.api_key),
        }
    }

    // URL TYPE 1: https://www.flickr.com/photos/gerdavs/52310534489/ <- remove last '/'
    // URL TYPE 2: https://flic.kr/p/2oRguN3
    // Both cases: Split with '/' and get last member (= photo_id).
    fn determine_photo_id(mut url: &str) -> Result<&str> {
        if !SHORT_URL_REGEX.is_match(url) && !LONG_URL_REGEX.is_match(url) {
            return Err(ImageHosterError::FormatNotFound(format!(
                "this url format is not supported: '{url}'"
            )));
        }
        url = url.trim_end_matches('/');
        let splits = url.split('/');
        splits.last().ok_or_else(|| {
            ImageHosterError::FormatNotFound(format!("this url format is not supported: '{url}'"))
        })
    }
}

#[async_trait]
impl ImageHoster for FlickeApiHandler {
    /// This method validates an url to an image hosted at flickr.com.
    /// # Errors
    /// If the url can't be compiled an [`ImageHosterError::FormatNotFound`] will be returned.<br>
    /// If the connection to flickr couldn't be established [`ImageHosterError::NotConnected`] will be returned.<br>
    /// If the flickr api isn't available [`ImageHosterError::ServiceUnavailable`] will be returned.<br>
    /// If some response couldn't be decode by this server [`ImageHosterError::DecodeFailed`] will be returned.<br>
    /// More error information is described here: [`ImageHosterError`].
    /// # Return
    /// If the image exists, the [`ImageMetaData`] struct will be returned.
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData> {
        let photo_id = Self::determine_photo_id(url)?;
        self.request.flickr_photos_get_sizes(photo_id).await
    }

    /// This method checks if an image hosted at flickr.com still exists.
    /// # Return
    /// True if the image exists. False if not.
    /// # Errors
    /// If errors occur, that not decide weather the image exists or not, they will be returned.
    async fn check_existence(&self, photo_id: &str) -> Result<bool> {
        let res = self.request.flickr_photos_get_sizes(photo_id).await;
        match res {
            Ok(_) => Ok(true),
            Err(error) => {
                if error == ImageHosterError::PhotoNotFound {
                    Ok(false)
                } else {
                    Err(error)
                }
            }
        }
    }

    /// This method checks if an image hosted at flickr.com has a valid license.
    /// A list of all valid licenses is here: [`json_parser::get_valid_licences`]
    /// # Return
    /// True if the image is published under a valid license. False if not.
    /// # Errors
    /// If any error occurs, it will be returned.
    async fn check_licence(&self, photo_id: &str) -> Result<bool> {
        self.request.flickr_photos_license_check(photo_id).await
    }
}

#[async_trait]
impl<T> ImageHoster for Arc<T>
where
    T: ImageHoster,
{
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData> {
        self.validate_url(url).await
    }

    async fn check_existence(&self, image_id: &str) -> Result<bool> {
        self.check_existence(image_id).await
    }

    async fn check_licence(&self, image_id: &str) -> Result<bool> {
        self.check_licence(image_id).await
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::flickr_api_handler::FlickeApiHandler;

    #[test]
    fn valid_determine_photo_id() {
        let valid_url = "https://flic.kr/p/2oRguN3";
        let res = FlickeApiHandler::determine_photo_id(valid_url).unwrap();
        assert_eq!(res, "2oRguN3");
    }

    #[test]
    fn empty_determine_photo_id() {
        let valid_url = "";
        let res = FlickeApiHandler::determine_photo_id(valid_url)
            .err()
            .unwrap();
        assert_eq!(
            res,
            ImageHosterError::FormatNotFound(format!(
                "this url format is not supported: '{valid_url}'"
            ))
        );
    }

    #[test]
    fn invalid_determine_photo_id() {
        let valid_url = "https://flic.kr/p/";
        let res = FlickeApiHandler::determine_photo_id(valid_url)
            .err()
            .unwrap();
        assert_eq!(
            res,
            ImageHosterError::FormatNotFound(format!(
                "this url format is not supported: '{valid_url}'"
            ))
        );
    }
}
