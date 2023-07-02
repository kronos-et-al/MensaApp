use crate::interface::mensa_parser::model::ParseCanteen;

struct HTMLParser;

impl HTMLParser {
    pub fn new() -> HTMLParser {
        HTMLParser
    }

    //TODO transform(&self, html: String) -> Option<ParseCanteen>
    pub fn transform(&self, html: String) -> Option<ParseCanteen> {
        OK()
    }
}