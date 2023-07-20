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



    pub fn new(info: HosterInfo) -> Result<Self, ImageHosterError> {
        Ok(Self {
            parser: XMLParser::new(),
            request: ApiRequest::new(info.api_key, info.client_timeout, info.client_user_agent)?,
        })
    }

    fn determine_photo_id(url: &str) -> Result<String, ImageHosterError> {
        if url.len() > 30 {
            let splits = &url.split('/');
            match splits[5] {
                None => Err(ImageHosterError::DecodeFailed(format!("Couldn't detect photo id in url {}", &url))),
                Some(s) => Ok(String::from(s))
            }
        } else {
            let splits = &url.split('/');
            match splits.last() {
                None => Err(ImageHosterError::DecodeFailed(format!("Couldn't detect photo id in url {}", &url))),
                Some(s) => Ok(String::from(s))
            }
        }
    }

    fn check_licence(licence: String) -> bool {
        for s in Self::get_valid_licences() {
            if s == licence {
                true
            }
        }
        false
    }

    // See https://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html for all possible licences.
    fn get_valid_licences() -> List<String> {
        vec![
            String::from("All Rights Reserved"),
            String::from("No known copyright restrictions"),
            String::from("Public Domain Dedication (CC0)"),
            String::from("Public Domain Mark")
        ]
    }
}

#[async_trait]
impl ImageHoster for FlickrApiHandler {

    async fn validate_url(&self, url: &str) -> Result<ImageMetaData, ImageHosterError> {
        let photo_id = FlickrApiHandler::determine_photo_id(url)?;
        self.parser.parse_to_image(self.request.flickr_photos_get_sizes(photo_id)?)?
    }

    async fn check_existence(&self, _photo_id: &str) -> bool {
        match self.request.flickr_photos_get_sizes(photo_id) {
            Ok(_) => true,
            Err(_) => false
        }
    }

    async fn check_licence(&self, _photo_id: &str) -> bool {
        FlickrApiHandler::check_licence(self.parser.get_licence(self.request.flickr_photos_licenses_get_license_history(photo_id)?)?)

    }
}