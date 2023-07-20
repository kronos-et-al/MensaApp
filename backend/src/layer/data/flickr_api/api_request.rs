
pub struct ApiRequest {
    api_key: String
}

impl ApiRequest {
    
    pub const fn new(api_key: String) -> Self {
        Self {
            api_key
        }
    }
}