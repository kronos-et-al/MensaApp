use std::time::Duration;
use async_trait::async_trait;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError};
use crate::interface::image_hoster::model::ImageMetaData;
use crate::layer::data::flickr_api::api_request::ApiRequest;
use crate::layer::data::flickr_api::xml_parser::XMLParser;

#[derive(Debug, Clone)]
pub struct HosterInfo {
    api_key: String,
    client_timeout: Duration,
    client_user_agent: String
}

pub struct FlickrApiHandler {
    parser: XMLParser,
    request: ApiRequest
}

impl FlickrApiHandler {

    pub const fn new(info: HosterInfo) -> Result<Self, ImageHosterError> {
        Ok(Self {
            parser: XMLParser::new(),
            request: ApiRequest::new(info.api_key, info.client_timeout, info.client_user_agent)?,
        })
    }
}

#[async_trait]
impl ImageHoster for FlickrApiHandler {

    async fn validate_url(&self, url: &str) -> crate::interface::image_hoster::Result<ImageMetaData> {
        todo!()
    }

    async fn check_existence(&self, photo_id: &str) -> crate::interface::image_hoster::Result<bool> {
        todo!()
    }

    async fn check_licence(&self, photo_id: &str) -> crate::interface::image_hoster::Result<bool> {
        todo!()
    }
}