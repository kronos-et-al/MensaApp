#![allow(clippy::unwrap_used)]
#![allow(dead_code)]
use crate::layer::data::swka_parser::swka_html_request::SwKaHtmlRequest;
use crate::layer::data::swka_parser::swka_link_creator::SwKaLinkCreator;
use crate::layer::data::swka_parser::swka_parse_manager::ParseInfo;
use std::time::Duration;

#[must_use]
pub fn get_mensa_names() -> Vec<String> {
    vec![
        String::from("mensa_adenauerring"),
        String::from("mensa_gottesaue"),
        String::from("mensa_moltke"),
        String::from("mensa_x1moltkestrasse"),
        String::from("mensa_erzberger"),
        String::from("mensa_tiefenbronner"),
        String::from("mensa_holzgarten"),
    ]
}

#[must_use]
pub fn get_base_url() -> String {
    String::from("https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/")
}

#[must_use]
pub const fn get_client_timeout() -> Duration {
    Duration::from_millis(6000)
}

#[must_use]
pub fn get_client_user_agent() -> String {
    String::from("User-Agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36")
}

#[must_use]
pub fn get_parse_info() -> ParseInfo {
    ParseInfo {
        base_url: get_base_url(),
        valid_canteens: get_mensa_names(),
        client_timeout: get_client_timeout(),
        client_user_agent: get_client_user_agent(),
    }
}

#[must_use]
pub fn get_creator() -> SwKaLinkCreator {
    SwKaLinkCreator::new(get_base_url(), get_mensa_names())
}

#[must_use]
pub fn get_request() -> SwKaHtmlRequest {
    SwKaHtmlRequest::new(get_client_timeout(), get_client_user_agent()).unwrap()
}
