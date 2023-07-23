use serde_json::Value::String;
use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::ImageHosterError;
use crate::layer::data::flickr_api::json_structs::{JsonRoot, JsonRootError, JsonRootLicense, JsonRootSizes};

pub struct JSONParser;

fn get_selected_size_fallback() -> String { String::from("Medium") }
fn get_selected_size() -> String { String::from("Large") }

impl JSONParser {
    pub const fn new() -> Self {
        Self
    }

    /// Obtains the preferred image information from the [`JsonRootSizes`] struct.
    /// # Return
    /// The [`ImageMetaData`] struct containing all necessary information for the image.
    /// If the preferred size cannot be obtained a fallback to a smaller size 'll be done.
    /// If even this fallback size is not available the url will be empty. No url 'll be provided.
    pub async fn parse_get_sizes(
        &self,
        root: JsonRootSizes,
        photo_id: &str
    ) -> Result<ImageMetaData, ImageHosterError> {
        let mut url = String::new();
        for size in root.sizes.size {
            if size.label == get_selected_size() {
                url = size.source;
                break;
            }
        }
        if url == String::new() {
            for size in root.sizes.size {
                if size.label == get_selected_size_fallback() {
                    url = size.source;
                    break;
                }
            }
        }
        Ok(ImageMetaData {
            id: String::from(photo_id),
            image_url: url,
        })
    }

    /// Obtains and validates the license by the information from the [`JsonRootLicense`] struct.
    /// # Return
    /// A boolean if the image has an valid license or not.
    /// If the image has no license or no license history, the image isn't restricted by any license and true 'll be returned.
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

    /// Obtains and determines an error by his error code and message provided by the [`JsonRootError`] struct.
    /// # Return
    /// An [`ImageHosterError`] that fittest be with the Flickr-Error types.
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
            String::new()
        ]
    }
}

#[cfg(test)]
mod test {

    #[tokio::test]
    pub async fn test_parse_to_image() {

    }
}