use std::future::Future;
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

    pub fn new(api_key: String) -> Result<ApiRequest, ImageHosterError> {
        Ok(Self {
            api_key,
            parser: JSONParser::new()
        })
    }

    async fn request_sizes(&self, url: &String) -> Result<JsonRootSizes, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootSizes>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_sizes finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res); // TODO remove
        Ok(res)
    }

    async fn request_license(&self, url: &String) -> Result<JsonRootLicense, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootLicense>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_license finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res); //TODO remove
        Ok(res)
    }

    async fn request_err(&self, url: &String) -> Result<JsonRootError, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootError>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_err finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res);
        Ok(res)
    }

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
        println!("flickr.photos.getSizes URL: {}", url); // TODO remove
        match self.request_sizes(&url).await {
            Ok(sizes) => Ok(self.parser.parse_get_sizes(sizes, photo_id)),
            Err(e) => Err(self.determine_error(url, e))
        }
    }

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
        println!("flickr.photos.licenses.getLicenseHistory URL: {}", url); // TODO remove
        match self.request_license(&url).await {
            Ok(licenses) => Ok(self.parser.check_license(licenses)),
            Err(e) => Err(self.determine_error(url, e))
        }
    }

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
    use super::*;
    use crate::layer::data::flickr_api::test::const_test_data::{
        get_api_key, get_client_timeout, get_client_user_agent
    };

    #[tokio::test]
    async fn test_get_sizes_valid() {
        let _req =
            ApiRequest::new(get_api_key(), get_client_timeout(), get_client_user_agent()).unwrap();
        let val = _req.flickr_photos_get_sizes("2nGvar4").await.unwrap();
        println!("val: {:?}", val);

        // TODO Test fails but these Strings are equal! Just their line separators are different (expected crlf got lf)
    }

    #[tokio::test]
    async fn test_get_licence_valid() {
        let _req =
            ApiRequest::new(get_api_key(), get_client_timeout(), get_client_user_agent()).unwrap();
        // TODO Test fails as the service is not available!
    }
}
