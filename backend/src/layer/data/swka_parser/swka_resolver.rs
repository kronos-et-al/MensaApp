use std::error::Error;

pub struct SwKaResolver;

impl SwKaResolver {
    pub fn new() -> SwKaResolver {
        Self
    }

    /// Calls get_html urls times. Returns multiple html code at once.
    /// TODO error handling and "url" fixes
    pub async fn get_htmls(&self, urls: Vec<String>) -> Result<Vec<String>, Box<dyn Error>> {
        todo!()
    }

    /// priv
    async fn get_html(&self, url: String) -> Result<String, Box<dyn Error>> {
        let resp = reqwest::get(url)
            .await?
            .text()
            .await?;
        Ok(resp)
    }
}