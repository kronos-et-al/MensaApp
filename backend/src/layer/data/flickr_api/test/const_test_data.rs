use dotenvy::dotenv;
use std::env;

/// For all valid tests this image 'll be used: https://flic.kr/p/2oRguN3

pub fn get_sizes_url(photo_id: String) -> String {
    format!("https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key={key}&photo_id={photo_id}&format=json&nojsoncallback=1", key = get_api_key())
}

pub fn get_licenses_url(photo_id: String) -> String {
    format!("https://api.flickr.com/services/rest/?method=flickr.photos.licenses.getLicenseHistory&api_key={key}&photo_id={photo_id}&format=json&nojsoncallback=1", key = get_api_key())
}

#[must_use]
pub fn get_api_key() -> String {
    dotenv().ok();
    env::var("FLICKR_PUBLIC_KEY").expect("FLICKR_PUBLIC_KEY should be set in the .env!")
}
