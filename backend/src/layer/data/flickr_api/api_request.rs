use std::time::Duration;
use crate::interface::image_hoster::ImageHosterError;

pub struct ApiRequest {
    api_key: String,
    client: reqwest::Client
}

impl ApiRequest {

    const TEST_URL: &'static str = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=ca370d51a054836007519a00ff4ce59e&per_page=10";

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

    pub fn flickr_photos_getSizes(api_key: String, photo_id: String) -> String {
        todo!()
    }

    pub fn flickr_photos_licenses_getLicenseHistory(api_key: String, photo_id: String) -> String {
        todo!()
    }
}