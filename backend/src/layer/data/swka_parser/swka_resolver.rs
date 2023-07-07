use std::error::Error;

pub struct SwKaResolver;

impl SwKaResolver {
    pub fn new() -> SwKaResolver {
        Self
    }

    /// Calls get_html urls times. Returns multiple html code at once.
    /// TODO error handling and "url" fixes
    pub async fn get_htmls(&self, urls: Vec<String>) -> Result<Vec<String>, Box<dyn Error>> {
        let mut htmls: Vec<String> = Vec::new();

        for ref url in urls {
            let mut tries = 3; //TODO Final or config?

            loop {
                tries = tries - 1;
                let html = self.get_html(url).await;
                if html.is_ok() {
                    htmls.push(html.unwrap());
                    break();
                } else {
                    if tries == 0 {
                        //Err(html.expect_err("Could not connect to url:"))
                        todo!();
                    }
                }
            }
        }
        Ok(htmls)
    }

    /// priv
    async fn get_html(&self, url: &String) -> Result<String, Box<dyn Error>> {
        let resp = reqwest::get(url)
            .await?
            .text()
            .await?;
        Ok(resp)
    }
}