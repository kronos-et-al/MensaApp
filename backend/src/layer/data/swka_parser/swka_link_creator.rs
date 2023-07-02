use crate::util::Date;

struct SwKaLinkCreator;

impl SwKaLinkCreator {
    pub fn new() -> SwKaLinkCreator {
        SwKaLinkCreator
    }
    //TODO impl get_urls(&self, day: Date) -> Vec<String>
    pub fn get_urls(&self, day: Date) -> Vec<String> {
        OK()
    }
    //TODO impl get_all_urls(&self) -> (Date, Vec<String>)
    pub fn get_all_urls(&self) -> (Date, Vec<String>) {
        OK()
    }
}