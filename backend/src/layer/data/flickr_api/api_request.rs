use std::time::Duration;
use tracing::log::debug;
use crate::interface::image_hoster::ImageHosterError;

pub struct ApiRequest {
    api_key: String,
    client: reqwest::Client
}

impl ApiRequest {

    const TEST_URL: &'static str = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=c761a4ffc2977f985d68edda64f178df&per_page=10";

    const BASE_URL: &'static str = "https://api.flickr.com/services/rest/?method=";
    const GET_SIZES: &'static str = "flickr.photos.getSizes";
    const GET_LICENCE_HISTORY: &'static str = "flickr.photos.licences.getLicenceHistory";

    const TAG_API_KEY: &'static str = "&api_key=";
    const TAG_PHOTO_ID: &'static str = "&photo_id=";
    const FORMAT: &'static str = "&format=json&nojsoncallback=1";

    pub const fn new(api_key: String, client_timeout: Duration, client_user_agent: String) -> Result<ApiRequest, ImageHosterError> {
        Ok(Self {
            api_key,
            client: Self::get_client(client_timeout, client_user_agent)?,
        })
    }

    fn get_client(
        client_timeout: Duration,
        client_user_agent: String,
    ) -> Result<reqwest::Client, ImageHosterError> {
        let client = reqwest::Client::builder()
            .timeout(client_timeout)
            .user_agent(client_user_agent)
            .build();
        client.map_err(|e| ImageHosterError::ClientBuilderFailed(e.to_string()))
    }

    async fn request(&self, url: String) -> Result<String, ImageHosterError> {
        let resp = self.client.get(url).send().await.map_err(|e| ImageHosterError::NotConnected)?;
        debug!("Url request finished: {:?}", resp);
        Ok(resp.json().await.map_err(|e| ImageHosterError::DecodeFailed(e))?)
    }

    pub async fn flickr_photos_get_sizes(&self, api_key: String, photo_id: String) -> String {
        let url = format!("{BASE_URL}{GET_SIZES}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{FORMAT}", BASE_URL = Self::BASE_URL, GET_SIZES = Self::GET_SIZES, TAG_API_KEY = Self::TAG_API_KEY, TAG_PHOTO_ID = Self::TAG_PHOTO_ID, FORMAT = Self::FORMAT);
        return self.request(url).await?;
    }

    pub async fn flickr_photos_licenses_get_license_history(&self, api_key: String, photo_id: String) -> String {
        let url = format!("{BASE_URL}{GET_LICENCE_HISTORY}{TAG_API_KEY}{api_key}{TAG_PHOTO_ID}{photo_id}{FORMAT}", BASE_URL = Self::BASE_URL, GET_LICENCE_HISTORY = Self::GET_LICENCE_HISTORY, TAG_API_KEY = Self::TAG_API_KEY, TAG_PHOTO_ID = Self::TAG_PHOTO_ID, FORMAT = Self::FORMAT);
        return self.request(url).await?;
    }
}

#[cfg(test)]
mod test {

}