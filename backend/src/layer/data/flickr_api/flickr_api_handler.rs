use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use async_trait::async_trait;

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

    // URL TYPE 1: https://www.flickr.com/photos/gerdavs/52310534489/ <- remove last '/'
    // URL TYPE 2: https://flic.kr/p/2nGvar4
    // Both cases: Split with '/' and get last member (= photo_id).
    fn determine_photo_id(&self, mut url: &str) -> Result<&str, ImageHosterError> {
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
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData, ImageHosterError> {
        let photo_id = self.determine_photo_id(url)?;
        self.request.flickr_photos_get_sizes(photo_id).await
    }

    async fn check_existence(&self, photo_id: &str) -> Result<bool, ImageHosterError> {
        self.check_licence(photo_id)
    }

    async fn check_licence(&self, photo_id: &str) -> Result<bool, ImageHosterError> {
        self.request.flickr_photos_licenses_get_license_history(photo_id).await
    }
}
