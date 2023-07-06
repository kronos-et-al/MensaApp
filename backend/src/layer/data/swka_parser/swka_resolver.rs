use std::error::Error;

pub struct SwKaResolver;

impl SwKaResolver {
    pub fn new() -> SwKaResolver {
        Self
    }

    /// priv
    //#[tokio::main]
    async fn get_html(&self, url: String) -> Result<String, Box<dyn Error>> {
        let resp = reqwest::get(url)
            .await?
            .text()
            .await?;
        Ok(resp)
    }

    /// Calls get_html urls times. Returns multiple html code at once.
    pub async fn get_htmls(&self, urls: Vec<String>) -> Vec<String> {
        let mut htmls: Vec<String> = Vec::new();

        for url in urls {
            let html = self.get_html(url).await;
            if html.is_ok() {
                htmls.push(html.unwrap());
            } else {
                //tries x times, for each url
                //Log error
            }

        }

        htmls
    }
}