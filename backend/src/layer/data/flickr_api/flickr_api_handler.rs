use std::sync::Arc;

use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError, Result};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use async_trait::async_trait;
use lazy_static::lazy_static;
use regex::Regex;
use tracing::trace;

#[derive(Debug)]
pub struct FlickrInfo {
    pub api_key: String,
}

pub struct FlickrApiHandler {
    request: ApiRequest,
}

lazy_static! {
    static ref LONG_URL_REGEX: Regex =
        Regex::new(r"https://www\.flickr\.com/photos/[\w@]+/(\d+)/?")
            .expect("regex creation failed");
    static ref SHORT_URL_REGEX: Regex =
        Regex::new(r"https://flic\.kr/p/(\w+)").expect("regex creation failed");
}

impl FlickrApiHandler {
    #[must_use]
    #[allow(clippy::missing_const_for_fn)] // cannot be made const because of compiler error
    pub fn new(info: FlickrInfo) -> Self {
        Self {
            request: ApiRequest::new(info.api_key),
        }
    }

    // URL TYPE Long 1.1: https://www.flickr.com/photos/gerdavs/52310534489/
    // URL TYPE Long 1.2: https://www.flickr.com/photos/198319418@N06/53077317043
    // URL TYPE Short 2: https://flic.kr/p/2oRguN3
    // Both cases: Split with '/' and get last member (= photo_id).
    fn determine_photo_id(url: &str) -> Result<String> {
        if let Some(groups) = SHORT_URL_REGEX.captures(url) {
            Ok(Self::decode(
                groups
                    .get(1)
                    .map(|m| m.as_str())
                    .expect("could not detect id group in url"),
            )?
            .to_string())
        } else if let Some(groups) = LONG_URL_REGEX.captures(url) {
            Ok(groups
                .get(1)
                .map(|m| m.as_str())
                .expect("could not detect id group in url")
                .to_string())
        } else {
            Err(ImageHosterError::FormatNotFound(format!(
                "this url format is not supported: '{url}'"
            )))
        }
    }

    fn decode(word: &str) -> Result<u64> {
        let bytes = bs58::decode(word)
            .with_alphabet(bs58::Alphabet::FLICKR)
            .into_vec()
            .map_err(|e| ImageHosterError::Bs58DecodeFailed(e.to_string()))?;
        let mut bytes: Vec<u8> = bytes.into_iter().rev().collect();
        bytes.resize(8, 0);
        // try_into() cannot fail as bytes.resize guarantees length 8.
        Ok(u64::from_le_bytes(bytes.try_into().expect(
            "Decode: convert failed as Vec<u8> could not be parsed into &[u8; 8]",
        )))
    }
}

#[async_trait]
impl ImageHoster for FlickrApiHandler {
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
        self.request.flickr_photos_get_sizes(&photo_id).await
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
    /// A list of all valid licenses:
    /// - `No known copyright restrictions`
    /// - `Public Domain Dedication (CC0)`
    /// - `Public Domain Mark`
    /// # Return
    /// True if the image is published under a valid license. False if not.
    /// # Errors
    /// If any error occurs, it will be returned.
    async fn check_licence(&self, photo_id: &str) -> Result<()> {
        let (valid, license) = self.request.flickr_photos_license_check(photo_id).await?;
        return if valid {
            Ok(())
        } else {
            Err(ImageHosterError::InvalidLicense(license))
        }

    }
}

#[async_trait]
impl<T> ImageHoster for Arc<T>
where
    T: ImageHoster,
{
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData> {
        let hoster: &T = self;
        hoster.validate_url(url).await
    }

    async fn check_existence(&self, image_id: &str) -> Result<bool> {
        let hoster: &T = self;
        hoster.check_existence(image_id).await
    }

    async fn check_licence(&self, image_id: &str) -> Result<()> {
        let hoster: &T = self;
        hoster.check_licence(image_id).await
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]

    use std::env;
    use std::sync::Arc;

    use async_trait::async_trait;
    use dotenvy::dotenv;

    use crate::interface::image_hoster::model::ImageMetaData;
    use crate::interface::image_hoster::{ImageHoster, ImageHosterError, Result};
    use crate::layer::data::flickr_api::flickr_api_handler::{FlickrApiHandler, FlickrInfo};

    fn get_api_key() -> String {
        dotenv().ok();
        env::var("FLICKR_API_KEY").expect("FLICKR_API_KEY should be set in the .env!")
    }

    #[test]
    fn test_valid_decode() {
        let word = "2oSg8aV";
        let res = FlickrApiHandler::decode(word).unwrap();
        assert_eq!(res, 53_077_317_043);
    }

    #[test]
    fn test_invalid_decode() {
        let word = "DU_K";
        let res = FlickrApiHandler::decode(word);
        assert!(res.is_err());
    }

    #[test]
    fn test_valid_determine_short_photo_id() {
        let valid_url = "https://flic.kr/p/2oRguN3";
        let res = FlickrApiHandler::determine_photo_id(valid_url).unwrap();
        assert_eq!(res, "53066073286");
    }

    #[test]
    fn test_valid_determine_long1_photo_id() {
        let valid_url = "https://www.flickr.com/photos/198319418@N06/53077317043";
        let res = FlickrApiHandler::determine_photo_id(valid_url).unwrap();
        assert_eq!(res, "53077317043");
    }

    #[test]
    fn test_valid_determine_long2_photo_id() {
        let valid_url = "https://www.flickr.com/photos/gerdavs/52310534489/";
        let res = FlickrApiHandler::determine_photo_id(valid_url).unwrap();
        assert_eq!(res, "52310534489");
    }

    #[test]
    fn test_invalid_determine_photo_id() {
        let valid_url = "https://www.flickr.com/photos/gerdavs/";
        let res = FlickrApiHandler::determine_photo_id(valid_url);
        assert!(res.is_err());
    }

    #[test]
    fn test_empty_determine_photo_id() {
        let valid_url = "";
        let res = FlickrApiHandler::determine_photo_id(valid_url)
            .err()
            .unwrap();
        assert_eq!(
            res,
            ImageHosterError::FormatNotFound(format!(
                "this url format is not supported: '{valid_url}'"
            ))
        );
    }

    #[tokio::test]
    async fn test_arc() {
        struct Mock;
        #[async_trait]
        impl ImageHoster for Mock {
            async fn validate_url(&self, _url: &str) -> Result<ImageMetaData> {
                Ok(ImageMetaData {
                    id: "id".into(),
                    image_url: "url".into(),
                })
            }

            async fn check_existence(&self, _image_id: &str) -> Result<bool> {
                Ok(true)
            }

            async fn check_licence(&self, _image_id: &str) -> Result<()> {
                Ok(())
            }
        }

        let arc = Arc::new(Mock);

        arc.check_existence("image_id").await.unwrap();
        arc.check_licence("image_id").await.unwrap();
        arc.validate_url("url").await.unwrap();
    }

    #[tokio::test]
    async fn test_validate_url() {
        let handler = FlickrApiHandler::new(FlickrInfo {
            api_key: get_api_key(),
        });
        let url = "https://www.flickr.com/photos/198319418@N06/53077317043";
        assert!(handler.validate_url(url).await.is_ok());
    }

    #[tokio::test]
    async fn test_check_license() {
        let handler = FlickrApiHandler::new(FlickrInfo {
            api_key: get_api_key(),
        });
        assert!(handler.check_licence("53077317043").await.is_ok());
    }

    #[tokio::test]
    async fn test_check_existence() {
        let handler = FlickrApiHandler::new(FlickrInfo {
            api_key: get_api_key(),
        });
        assert!(handler.check_existence("53077317043").await.is_ok());
    }
}
