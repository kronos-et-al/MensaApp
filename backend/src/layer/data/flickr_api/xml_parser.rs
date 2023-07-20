use crate::interface::image_hoster::model::ImageMetaData;

pub struct XMLParser;

impl XMLParser {
    pub const fn new() -> Self {
        Self
    }

    pub fn parse_to_image(xml: String) -> ImageMetaData {
        todo!()
    }

    pub fn get_licence(xml: String) -> String {
        todo!()
    }
}