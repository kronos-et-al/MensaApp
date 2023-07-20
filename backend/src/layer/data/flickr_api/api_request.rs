
pub struct ApiRequest {
    api_key: String
}

impl ApiRequest {

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