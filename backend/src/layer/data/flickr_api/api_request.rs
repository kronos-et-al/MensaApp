use crate::interface::image_hoster::ImageHosterError;
use reqwest::Client;
use std::time::Duration;
use tracing::log::debug;

pub struct ApiRequest {
    api_key: String,
    client: Client,
}

impl ApiRequest {
    const TEST_URL: &'static str = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=ca370d51a054836007519a00ff4ce59e&per_page=10";

    const BASE_URL: &'static str = "https://api.flickr.com/services/rest/?method=";
    const GET_SIZES: &'static str = "flickr.photos.getSizes";
    const GET_LICENCE_HISTORY: &'static str = "flickr.photos.licenses.getLicenseHistory";

    const TAG_API_KEY: &'static str = "&api_key=";
    const TAG_PHOTO_ID: &'static str = "&photo_id=";
    const FORMAT: &'static str = "&format=json&nojsoncallback=1";

    pub fn new(
        api_key: String,
        client_timeout: Duration,
        client_user_agent: String,
    ) -> Result<ApiRequest, ImageHosterError> {
        Ok(Self {
            api_key,
            client: Self::get_client(client_timeout, client_user_agent)?,
        })
    }

    fn get_client(
        client_timeout: Duration,
        client_user_agent: String,
    ) -> Result<Client, ImageHosterError> {
        let client = Client::builder()
            .timeout(client_timeout)
            .user_agent(client_user_agent)
            .build();
        client.map_err(|e| ImageHosterError::ClientBuilderFailed(e.to_string()))
    }

    async fn request(&self, url: String) -> Result<String, ImageHosterError> {
        let resp = self
            .client
            .get(url)
            .send()
            .await
            .map_err(|_| ImageHosterError::NotConnected)?;
        debug!("Url request finished: {:?}", resp);
        let res = resp
            .text()
            .await
            .map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        println!("{}", res); // TODO remove
        Ok(res)
    }

    pub async fn flickr_photos_get_sizes(
        &self,
        photo_id: &str,
    ) -> Result<String, ImageHosterError> {
        let url = format!(
            "{BASE_URL}{GET_SIZES}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}",
            BASE_URL = Self::BASE_URL,
            GET_SIZES = Self::GET_SIZES,
            TAG_API_KEY = Self::TAG_API_KEY,
            api_key = self.api_key,
            TAG_PHOTO_ID = Self::TAG_PHOTO_ID
        );
        println!("{}", url); // TODO remove
        Ok(self.request(url).await?)
    }

    pub async fn flickr_photos_licenses_get_license_history(
        &self,
        photo_id: &str,
    ) -> Result<String, ImageHosterError> {
        let url = format!(
            "{BASE_URL}{GET_LICENCE_HISTORY}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}",
            BASE_URL = Self::BASE_URL,
            GET_LICENCE_HISTORY = Self::GET_LICENCE_HISTORY,
            TAG_API_KEY = Self::TAG_API_KEY,
            api_key = self.api_key,
            TAG_PHOTO_ID = Self::TAG_PHOTO_ID
        );
        println!("{}", url); // TODO remove
        Ok(self.request(url).await?)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::layer::data::flickr_api::test::const_test_data::{
        get_api_key, get_client_timeout, get_client_user_agent, get_expected_get_licence_result,
        get_expected_get_size_result, get_valid_photo_id,
    };

    #[tokio::test]
    async fn test_get_sizes_valid() {
        let req =
            ApiRequest::new(get_api_key(), get_client_timeout(), get_client_user_agent()).unwrap();
        // TODO Test fails but these Strings are equal! Just their line separators are different (expected crlf got lf)
        assert_eq!(
            req.flickr_photos_get_sizes(get_valid_photo_id())
                .await
                .unwrap(),
            get_expected_get_size_result()
        )
    }

    #[tokio::test]
    async fn test_get_licence_valid() {
        let req =
            ApiRequest::new(get_api_key(), get_client_timeout(), get_client_user_agent()).unwrap();
        // TODO Test fails as the service is not available!
        assert_eq!(
            req.flickr_photos_licenses_get_license_history(get_valid_photo_id())
                .await
                .unwrap(),
            get_expected_get_licence_result()
        )
    }
}
