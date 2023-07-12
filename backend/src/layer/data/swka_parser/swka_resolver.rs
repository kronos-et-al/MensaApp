use futures::future::join_all;
use crate::layer::data::swka_parser::html_parser::ParseError;

pub struct SwKaResolver;

impl SwKaResolver {
    pub const fn new() -> Self {
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
        match resp.text().await {
            Ok(s) => Ok(s),
            Err(_e) => Err(ParseError::DecodeFailed)
        }
    }
}

#[cfg(test)]
mod test {
    use crate::layer::data::swka_parser::html_parser::ParseError;
    use crate::layer::data::swka_parser::swka_resolver::SwKaResolver;

    fn get_invalid_url() -> String { String::from("A ship-shipping ship ships shipping-ships") }
    fn get_valid_url() -> String { String::from("https://www.google.de") }

    #[tokio::test]
    async fn get_html_response_fail() {
        let result = SwKaResolver::new().get_html(&get_invalid_url()).await;
        assert!(matches!(result, Err(ParseError::NoConnectionEstablished)));
    }

    #[tokio::test]
    async fn get_html_response_no_fail() {
        let result = SwKaResolver::new().get_html(&get_valid_url()).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn get_html_strings_response_fail() {
        let urls = vec![get_invalid_url(), get_valid_url(), get_valid_url()];
        let result = SwKaResolver::new().get_html_strings(urls).await;
        assert!(matches!(result, Err(ParseError::NoConnectionEstablished)));
    }

    #[tokio::test]
    async fn get_html_strings_response_no_fail() {
        let urls = vec![get_valid_url(), get_valid_url()];
        let result = SwKaResolver::new().get_html_strings(urls).await;
        assert!(result.is_ok());
    }


}
