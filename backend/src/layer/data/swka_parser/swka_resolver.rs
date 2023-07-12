use std::error::Error;
use std::fmt::Error;

use futures::future::join_all;
use crate::layer::data::swka_parser::html_parser::ParseError;

pub struct SwKaResolver;

impl SwKaResolver {
    pub fn new() -> SwKaResolver {
        Self
    }

    pub async fn get_htmls(&self, urls: Vec<String>) -> Result<Vec<String>, ParseError> {
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
