
pub struct ApiRequest {
    api_key: String
}

impl ApiRequest {

    const TEST_URL: &'static str = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=ca370d51a054836007519a00ff4ce59e&per_page=10";

    const BASE_URL: &'static str = "https://api.flickr.com/services/rest/?method=";
    const GET_SIZES: &'static str = "flickr.photos.getSizes";
    const GET_LICENCE_HISTORY: &'static str = "flickr.photos.licences.getLicenceHistory";

    const TAG_API_KEY: &'static str = "&api_key=";
    const TAG_PHOTO_ID: &'static str = "&photo_id=";
    const FORMAT: &'static str = "&format=json&nojsoncallback=1";

    pub const fn new(api_key: String) -> Self {
        Self {
            api_key
        }
    }

    pub fn flickr_photos_getSizes(api_key: String, photo_id: String) -> String {
        todo!()
    }

    pub fn flickr_photos_licenses_getLicenseHistory(api_key: String, photo_id: String) -> String {
        todo!()
    }
}