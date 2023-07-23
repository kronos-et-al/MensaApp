use std::time::Duration;
use std::{env, fs};
use dotenvy::dotenv;
use reqwest::Client;

/// For all valid tests this image 'll be used: https://www.flickr.com/photos/gerdavs/52310534489/

pub fn get_expected_get_size_result() -> String {
    fs::read_to_string("./src/layer/data/flickr_api/test_data/valid_sizes_response.txt").unwrap()
}

pub fn get_expected_get_licence_result() -> String {
    fs::read_to_string("./src/layer/data/flickr_api/test_data/valid_licence_response.txt").unwrap()
}

pub fn get_sizes_url(photo_id: String) -> String {
    format!("https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key={key}&photo_id={photo_id}&format=json&nojsoncallback=1", key = get_api_key())
}

pub fn get_licenses_url(photo_id: String) -> String {
    format!("https://api.flickr.com/services/rest/?method=flickr.photos.licenses.getLicenseHistory&api_key={key}&photo_id={photo_id}&format=json&nojsoncallback=1", key = get_api_key())
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
pub fn get_client() -> Client {
    Client::builder()
        .timeout(get_client_timeout())
        .user_agent(get_client_user_agent())
        .build().unwrap()
}

#[must_use]
pub fn get_api_key() -> String {
    dotenv().ok();
    env::var("FLICKR_PUBLIC_KEY").expect("FLICKR_PUBLIC_KEY should be set in the .env!")
}
