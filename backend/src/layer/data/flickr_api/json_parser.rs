use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::ImageHosterError;
use crate::layer::data::flickr_api::json_structs::{JsonRoot, JsonRootError, JsonRootLicense, JsonRootSizes};

pub struct JSONParser;

fn GET_SELECTED_SIZE() -> String { String::from("Medium 800") }

impl JSONParser {
    pub const fn _new() -> Self {
        Self
    }

    pub async fn parse_get_sizes(
        &self,
        root: JsonRootSizes,
        photo_id: &str
    ) -> Result<ImageMetaData, ImageHosterError> {
        let mut url = String::new();
        for size in root.sizes.size {
            if size.label == GET_SELECTED_SIZE() {
                url = size.source;
                break;
            }
        }
        Ok(ImageMetaData {
            id: String::from(photo_id),
            image_url: url,
        })
    }

    pub fn check_license(&self, root: JsonRootLicense) -> bool {
        let mut last_date: u64 = 0;
        for entry in root.rsp.license_history.into_iter() {
            if last_date < entry.date_change {
                last_date = entry.date_change;
            }
        }
        let mut license: String = String::new();
        for entry in root.rsp.license_history {
            if entry.date_change == last_date {
                license = entry.new_license;
            }
        }
        for valid_license in self.get_valid_licences(){
            if valid_license == license {
                true
            }
        }
        false
    }

    pub fn parse_error(&self, err_info: JsonRootError) -> ImageHosterError {
        let err_code = err_info.rsp.err.code;
        let err_msg = err_info.rsp.err.msg;
        match err_code {
            1 => ImageHosterError::PhotoNotFound,
            2 => ImageHosterError::PermissionDenied,
            100 => ImageHosterError::InvalidApiKey,
            0 => ImageHosterError::ServiceUnavailable,
            105 => ImageHosterError::ServiceUnavailable,
            111 => ImageHosterError::FormatNotFound(err_msg),
            112 => ImageHosterError::FormatNotFound(err_msg),
            _ => ImageHosterError::SomethingWentWrong(err_msg),
        }
    }

    /// See https://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html for all possible licenses.
    fn get_valid_licences(&self) -> Vec<String> {
        vec![
            String::from("All Rights Reserved"),
            String::from("No known copyright restrictions"),
            String::from("Public Domain Dedication (CC0)"),
            String::from("Public Domain Mark"),
        ]
    }
}

#[cfg(test)]
mod test {

    #[tokio::test]
    pub async fn test_parse_to_image() {

    }
}