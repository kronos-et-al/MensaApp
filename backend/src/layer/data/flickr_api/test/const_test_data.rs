use std::time::Duration;
use std::{env, fs};
use dotenvy::dotenv;

/// For all valid tests this image 'll be used: https://www.flickr.com/photos/gerdavs/52310534489/

pub fn get_expected_get_size_result() -> String {
    fs::read_to_string("./src/layer/data/flickr_api/test_data/valid_sizes_response.txt").unwrap()
}

pub fn get_expected_get_licence_result() -> String {
    fs::read_to_string("./src/layer/data/flickr_api/test_data/valid_licence_response.txt").unwrap()
}

#[must_use]
pub fn get_valid_photo_id() -> &'static str {
    "2nGvar4" // "2nGvar4" or "52310534489"
}

#[must_use]
pub const fn get_client_timeout() -> Duration {
    Duration::from_millis(4000)
}

#[must_use]
pub fn get_client_user_agent() -> String {
    String::from("User-Agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
}

#[must_use]
pub fn get_api_key() -> String {
    // TODO get from .env. For now this is a public accessible example key from the internet.
    dotenv().ok();
    env::var("FLICKR_PUBLIC_KEY").unwrap()
    //String::from("ca370d51a054836007519a00ff4ce59e")
}
