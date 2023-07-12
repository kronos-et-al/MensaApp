use std::error::Error;
use std::fmt::Error;

use futures::future::join_all;
use crate::layer::data::swka_parser::html_parser::ParseError;

pub struct SwKaResolver;

impl SwKaResolver {
    pub fn new() -> SwKaResolver {
        Self
    }

    /// This function provides html code, which will be requested with the given url.<br>
    /// If the request or the decoding fails an error will be thrown. <br>
    /// `urls: Vec<String>` <br> urls to the requested html strings.<br>
    /// **Return** <br> All html strings obtained by the urls as `Vec<String>`.
    pub async fn get_html_strings(&self, urls: Vec<String>) -> Result<Vec<String>, ParseError> {
        join_all(urls.iter().map(|url| self.get_html(url)))
            .await
            .into_iter()
            .collect() // TODO hat happens when only some requests fail?
    }

    
    async fn get_html(&self, url: &String) -> Result<String, ParseError> {
        let resp = match reqwest::get(url).await {
            Ok(url_data) => url_data,
            Err(e) => return Err(ParseError::NoConnectionEstablished)
        };
        return match resp.text().await {
            Ok(s) => Ok(s),
            Err(e) => Err(ParseError::DecodeFailed)
        }
    }
}
