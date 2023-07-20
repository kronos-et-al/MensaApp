use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::{ImageHoster, ImageHosterError};
use crate::layer::data::flickr_api::api_request::ApiRequest;
use crate::layer::data::flickr_api::xml_parser::XMLParser;
use async_trait::async_trait;
use std::time::Duration;

#[derive(Debug, Clone)]
pub struct HosterInfo {
    api_key: String,
    client_timeout: Duration,
    client_user_agent: String,
}

pub struct FlickrApiHandler {
    parser: XMLParser,
    request: ApiRequest,
}

impl FlickrApiHandler {
    pub fn new(info: HosterInfo) -> Result<Self, ImageHosterError> {
        Ok(Self {
            parser: XMLParser::new(),
            request: ApiRequest::new(info.api_key, info.client_timeout, info.client_user_agent)?,
        })
    }

    fn determine_photo_id(url: &str) -> Result<&str, ImageHosterError> {
        if url.len() > 30 {
            let splits = &url.split('/');
            match splits[5] {
                // TODO redo
                None => Err(ImageHosterError::DecodeFailed(format!(
                    "Couldn't detect photo id in url {}",
                    &url
                ))),
                Some(s) => Ok(s),
            }
        } else {
            let splits = &url.split('/');
            match splits.last() {
                None => Err(ImageHosterError::DecodeFailed(format!(
                    "Couldn't detect photo id in url {}",
                    &url
                ))),
                Some(s) => Ok(s),
            }
        }
    }

    fn check_licence(licence: String) -> bool {
        for s in Self::get_valid_licences() {
            if s == licence {
                return true;
            }
        }
        return false;
    }

    // See https://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html for all possible licences.
    fn get_valid_licences() -> Vec<String> {
        vec![
            String::from("All Rights Reserved"),
            String::from("No known copyright restrictions"),
            String::from("Public Domain Dedication (CC0)"),
            String::from("Public Domain Mark"),
        ]
    }
}

#[async_trait]
impl ImageHoster for FlickrApiHandler {
    async fn validate_url(&self, url: &str) -> Result<ImageMetaData, ImageHosterError> {
        let photo_id = FlickrApiHandler::determine_photo_id(url)?;
        let licence = self.parser.get_licence(
            self.request
                .flickr_photos_licenses_get_license_history(&photo_id),
        );
        self.parser.parse_to_image(
            self.request.flickr_photos_get_sizes(&photo_id)?,
            photo_id,
            licence,
        )?
    }

    async fn check_existence(&self, photo_id: &str) -> bool {
        match self.request.flickr_photos_get_sizes(photo_id) {
            Ok(_) => true,
            Err(_) => false,
        }
    }

    async fn check_licence(&self, photo_id: &str) -> bool {
        FlickrApiHandler::check_licence(
            self.parser.get_licence(
                self.request
                    .flickr_photos_licenses_get_license_history(photo_id)?,
            )?,
        )
    }
}
