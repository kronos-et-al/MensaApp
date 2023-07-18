//! [`SwKaResolver`] for obtaining html code from urls.

use std::error::Error;
use crate::interface::mensa_parser::ParseError;
use futures::future::join_all;
use reqwest::Client;
use std::time::Duration;
use tracing::log::debug;

pub struct SwKaResolver {
    client_timeout: Duration,
    client_user_agent: String,
}

impl SwKaResolver {
    #[must_use]
    pub const fn new(client_timeout: Duration, client_user_agent: String) -> Self {
        Self {
            client_timeout,
            client_user_agent,
        }
    }

    fn get_client(&self) -> Result<Client, ParseError> {
        let client = Client::builder()
            .timeout(self.client_timeout)
            .user_agent(&self.client_user_agent)
            .build();
        client.map_err(|e| ParseError::ClientBuilderFailed(e.to_string()))
    }

    /// This function provides html code, which will be requested with the given url.
    /// `urls: Vec<String>` <br> urls to the requested html strings.
    /// ## Return
    /// All html strings obtained by the urls as `Vec<String>`.
    /// # Errors
    /// If the request or the decoding fails an [`ParseError`] will be returned.
    pub async fn get_html_strings(&self, urls: Vec<String>) -> Result<Vec<String>, ParseError> {
        join_all(urls.iter().map(|url| self.get_html(url)))
            .await
            .into_iter()
            .collect()
    }

    async fn get_html(&self, url: &String) -> Result<String, ParseError> {
        let resp = self
            .get_client()?
            .get(url)
            .send()
            .await
            .map_err(|e| ParseError::NoConnectionEstablished(e.to_string()))?;
        debug!("Url request finished: {:?}", resp);
        resp.text().await.map_err(|e| ParseError::DecodeFailed(e.to_string()))
    }
}

#[cfg(test)]
mod test {
    use crate::layer::data::swka_parser::util;

    fn get_invalid_url() -> String {
        String::from("A ship-shipping ship ships shipping-ships")
    }
    fn get_valid_url() -> String {
        String::from("https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/mensa_adenauerring/")
    }

    #[tokio::test]
    async fn get_html_response_fail() {
        let result = util::get_resolver().get_html(&get_invalid_url()).await;
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn get_html_response_no_fail() {
        let result = util::get_resolver().get_html(&get_valid_url()).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn get_html_strings_response_fail() {
        let urls = vec![get_invalid_url(), get_valid_url(), get_valid_url()];
        let result = util::get_resolver().get_html_strings(urls).await;
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn get_html_strings_response_no_fail() {
        let urls = vec![get_valid_url(), get_valid_url()];
        let result = util::get_resolver().get_html_strings(urls).await;
        assert!(result.is_ok());
    }
}
