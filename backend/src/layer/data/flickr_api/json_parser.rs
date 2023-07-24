use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::ImageHosterError;
use crate::layer::data::flickr_api::json_structs::*;

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
    pub fn parse_get_sizes(&self, root: JsonRootSizes, photo_id: &str) -> ImageMetaData {
        let mut url = String::new();
        for size in root.sizes.size.clone() {
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
        ImageMetaData {
            id: String::from(photo_id),
            image_url: url,
        }
    }

    /// Obtains and validates the license by the information from the [`JsonRootLicense`] struct.
    /// # Return
    /// A boolean if the image has an valid license or not.
    /// If the image has no license or no license history, the image isn't restricted by any license and true 'll be returned.
    pub fn check_license(&self, root: JsonRootLicense) -> bool {
        let mut last_date: u64 = 0;
        for entry in root.license_history.clone() {
            if last_date < entry.date_change {
                last_date = entry.date_change;
            }
        }
        let mut license: String = String::new();
        for entry in root.license_history {
            if entry.date_change == last_date {
                license = entry.new_license;
            }
        }
        for valid_license in Self::get_valid_licences(){
            if valid_license == license {
                return true;
            }
        }
        return false;
    }

    /// Obtains and determines an error by his error code and message provided by the [`JsonRootError`] struct.
    /// # Return
    /// An [`ImageHosterError`] that fittest be with the Flickr-Error types.
    pub fn parse_error(&self, err_info: JsonRootError) -> ImageHosterError {
        let err_code = &err_info.code;
        let err_msg = &err_info.message;
        match err_code {
            1 => ImageHosterError::PhotoNotFound,
            2 => ImageHosterError::PermissionDenied,
            100 => ImageHosterError::InvalidApiKey,
            0 | 105 => ImageHosterError::ServiceUnavailable,
            111 | 112 => ImageHosterError::FormatNotFound(err_msg.clone()),
            _ => ImageHosterError::SomethingWentWrong(err_msg.clone()),
        }
    }

    /// See https://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html for all possible licenses.
    fn get_valid_licences() -> Vec<String> {
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
    use crate::interface::image_hoster::ImageHosterError;
    use crate::interface::image_hoster::model::ImageMetaData;
    use crate::layer::data::flickr_api::json_parser::JSONParser;
    use crate::layer::data::flickr_api::json_structs::*;

    #[test]
    fn valid_get_size() {
        let valid_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: String::from("Medium"),
                        width: 800,
                        height: 600,
                        source: String::from("url:medium")
                    },
                    Size {
                        label: String::from("Large"),
                        width: 1000,
                        height: 800,
                        source: String::from("url:large")
                    }
                ],
            }
        };
        let dummy_id = "42";
        let res = JSONParser::new().parse_get_sizes(valid_sizes, dummy_id);
        let expect = ImageMetaData {
            id: String::from(dummy_id),
            image_url: String::from("url:large"),
        };
        assert_eq!(res.id, expect.id);
        assert_eq!(res.image_url, expect.image_url);
    }

    #[test]
    fn fallback_get_size() {
        let fallback_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: String::from("Medium"),
                        width: 800,
                        height: 600,
                        source: String::from("url:medium")
                    },
                    Size {
                        label: String::from("Small"),
                        width: 400,
                        height: 200,
                        source: String::from("url:small")
                    }
                ],
            }
        };
        let dummy_id = "42";
        let res = JSONParser::new().parse_get_sizes(fallback_sizes, dummy_id);
        let expect = ImageMetaData {
            id: String::from(dummy_id),
            image_url: String::from("url:medium"),
        };
        assert_eq!(res.id, expect.id);
        assert_eq!(res.image_url, expect.image_url);
    }

    #[test]
    fn invalid_get_size() {
        let invalid_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: String::from("Small"),
                        width: 400,
                        height: 200,
                        source: String::from("url:small")
                    }
                ],
            }
        };
        let dummy_id = "42";
        let res = JSONParser::new().parse_get_sizes(invalid_sizes, dummy_id);
        let expect = ImageMetaData {
            id: String::from(dummy_id),
            image_url: String::new(),
        };
        assert_eq!(res.id, expect.id);
        assert_eq!(res.image_url, expect.image_url);
    }

    #[test]
    fn valid_check_license()  {
        let valid_licenses = JsonRootLicense {
                license_history: vec![
                    LicenceHistory {
                        date_change: 1295918034,
                        old_license: String::from("All Rights Reserved"),
                        new_license: String::from("Attribution License"),
                    },
                    LicenceHistory {
                        date_change: 1598990519,
                        old_license: String::from("Attribution License"),
                        new_license: String::from("All Rights Reserved"),
                    }
                ],
        };
        assert!(JSONParser::new().check_license(valid_licenses))
    }

    #[test]
    fn valid_parse_error() {
        let valid_error = JsonRootError {
            stat: String::new(),
            code: 0,
            message: String::from("Sorry, the Flickr API service is not currently available."),
        };
        let res = JSONParser::new().parse_error(valid_error);
        assert_eq!(res, ImageHosterError::ServiceUnavailable)
    }

    #[test]
    fn invalid_parse_error() {
        let invalid_error = JsonRootError {
            stat: String::new(),
            code: 42,
            message: String::from("HELP!"),
        };
        let res = JSONParser::new().parse_error(invalid_error);
        assert_eq!(res, ImageHosterError::SomethingWentWrong(String::from("HELP!")))
    }
}