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

    /// Creates an instance of an [`ApiRequest`].
    pub fn new(api_key: String) -> Self {
        Self {
            api_key,
            parser: JSONParser::new()
        }
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootSizes`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_sizes(&self, url: &String) -> Result<JsonRootSizes, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootSizes>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_sizes finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res); // TODO remove
        Ok(res)
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootLicense`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_license(&self, url: &String) -> Result<JsonRootLicense, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootLicense>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_license finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res); //TODO remove
        Ok(res)
    }

    /// Sends a url request to the FlickrApi.
    /// # Return
    /// The [`JsonRootError`] struct, containing the api response.
    /// # Errors
    /// If the request could not be decoded to json or the connection could not be established, an error will be returned.
    async fn request_err(&self, url: &String) -> Result<JsonRootError, ImageHosterError> {
        let res = reqwest::get(url).await.map_err(|_| ImageHosterError::NotConnected)?.json::<JsonRootError>().await.map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        debug!("request_err finished: {:?}", res);
        println!("PRINT VALUE: {:?}", res);
        Ok(res)
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
        println!("flickr.photos.getSizes URL: {}", url); // TODO remove
        match self.request_sizes(&url).await {
            Ok(sizes) => Ok(self.parser.parse_get_sizes(sizes, photo_id)),
            Err(e) => Err(self.determine_error(url, e))
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
        println!("flickr.photos.licenses.getLicenseHistory URL: {}", url); // TODO remove
        match self.request_license(&url).await {
            Ok(licenses) => Ok(self.parser.check_license(licenses)),
            Err(e) => Err(self.determine_error(url, e))
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

}
