use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use async_trait::async_trait;
use std::ops::Index;

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

    fn determine_photo_id(url: &str) -> Result<&str, ImageHosterError> {
        let splits: Vec<&str> = url.split('/').collect();
        if url.len() > 30 {
            Ok(splits.index(5)) // TODO match
        } else {
            Ok(splits.last().copied().unwrap()) // TODO match
        }
    }


}

#[async_trait]
impl ImageHoster for FlickrApiHandler {
    async fn validate_url(&self, _url: &str) -> Result<ImageMetaData, ImageHosterError> {
        todo!()
    }

    async fn check_existence(&self, _photo_id: &str) -> Result<bool, ImageHosterError> {
        todo!()
    }

    async fn check_licence(&self, _photo_id: &str) -> Result<bool, ImageHosterError> {
        todo!()
    }
}
