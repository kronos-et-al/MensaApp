use crate::util::Date;

struct SwKaLinkCreator;

impl SwKaLinkCreator {

    //See <https://youtrack.friedrich-willhelm-der-schredder.de/articles/PSE-A-115/SwKaLinkCreator> for more information

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