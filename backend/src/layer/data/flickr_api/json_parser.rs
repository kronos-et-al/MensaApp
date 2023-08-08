use crate::interface::image_hoster::model::ImageMetaData;
use crate::interface::image_hoster::ImageHosterError;
use crate::layer::data::flickr_api::json_structs::{JsonRootError, JsonRootLicense, JsonRootSizes};

pub struct JsonParser;

const PREFERRED_SIZE: &str = "Large";
const FALLBACK_SIZE: &str = "Medium";

// See https://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html for all possible licenses.
const VALID_LICENSES: [&str; 3] = [
    "No known copyright restrictions",
    "Public Domain Dedication (CC0)",
    "Public Domain Mark",
];

impl JsonParser {
    /// Obtains the preferred image information from the [`JsonRootSizes`] struct.
    /// # Return
    /// The [`ImageMetaData`] struct containing all necessary information for the image.
    /// If the preferred size cannot be obtained a fallback to a smaller size will be done.
    /// If even this fallback size is not available the url will be empty. No url will be provided.
    /// # Errors
    /// Returns [`ImageHosterError::ImageIsTooSmall`] if the image is too small.
    pub fn parse_get_sizes(
        root: &JsonRootSizes,
        photo_id: &str,
    ) -> Result<ImageMetaData, ImageHosterError> {
        let mut url = root
            .sizes
            .size
            .iter()
            .find(|s| s.label == PREFERRED_SIZE)
            .map(|s| s.source.clone());

        if url.is_none() {
            url = root
                .sizes
                .size
                .iter()
                .find(|s| s.label == FALLBACK_SIZE)
                .map(|s| s.source.clone());
        }

        url.map_or(Err(ImageHosterError::ImageIsTooSmall), |url| {
            Ok(ImageMetaData {
                id: String::from(photo_id),
                image_url: url,
            })
        })
    }

    /// Obtains and validates the license by the information from the [`JsonRootLicense`] struct.
    /// # Return
    /// A boolean if the image has an valid license or not.
    /// If the image has no license or no license history, the image isn't restricted by any license and true will be returned.
    #[must_use]
    pub fn check_license(root: &JsonRootLicense) -> bool {
        let license = root
            .license_history
            .iter()
            .max_by_key(|l| l.date_change)
            .map(|entry| &entry.new_license);

        if let Some(license) = license {
            return VALID_LICENSES.contains(&license.as_str());
        }
        false
    }

    /// Obtains and determines an error by its error code and message provided by the [`JsonRootError`] struct.
    /// # Return
    /// An [`ImageHosterError`] that fittest be with the Flickr-Error types.
    #[must_use]
    pub fn parse_error(err_info: &JsonRootError) -> ImageHosterError {
        let err_code = err_info.code;
        let err_msg = err_info.message.clone();
        match err_code {
            1 => ImageHosterError::PhotoNotFound,
            2 => ImageHosterError::PermissionDenied,
            100 => ImageHosterError::InvalidApiKey,
            0 | 105 => ImageHosterError::ServiceUnavailable,
            111 | 112 => ImageHosterError::FormatNotFound(err_msg),
            _ => ImageHosterError::SomethingWentWrong(err_msg),
        }
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::interface::image_hoster::model::ImageMetaData;
    use crate::interface::image_hoster::ImageHosterError;
    use crate::layer::data::flickr_api::json_parser::JsonParser;
    use crate::layer::data::flickr_api::json_structs::JsonRootError;
    use crate::layer::data::flickr_api::json_structs::JsonRootLicense;
    use crate::layer::data::flickr_api::json_structs::JsonRootSizes;
    use crate::layer::data::flickr_api::json_structs::LicenceHistory;
    use crate::layer::data::flickr_api::json_structs::Size;
    use crate::layer::data::flickr_api::json_structs::Sizes;

    #[test]
    fn test_valid_get_size() {
        let valid_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: String::from("Medium"),
                        source: String::from("url:medium"),
                    },
                    Size {
                        label: String::from("Large"),
                        source: String::from("url:large"),
                    },
                ],
            },
        };
        let dummy_id = "42";
        let res = JsonParser::parse_get_sizes(&valid_sizes, dummy_id).unwrap();
        let expect = ImageMetaData {
            id: String::from(dummy_id),
            image_url: String::from("url:large"),
        };
        assert_eq!(res.id, expect.id);
        assert_eq!(res.image_url, expect.image_url);
    }

    #[test]
    fn test_fallback_get_size() {
        let fallback_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![
                    Size {
                        label: String::from("Medium"),
                        source: String::from("url:medium"),
                    },
                    Size {
                        label: String::from("Small"),
                        source: String::from("url:small"),
                    },
                ],
            },
        };
        let dummy_id = "42";
        let res = JsonParser::parse_get_sizes(&fallback_sizes, dummy_id).unwrap();
        let expect = ImageMetaData {
            id: String::from(dummy_id),
            image_url: String::from("url:medium"),
        };
        assert_eq!(res.id, expect.id);
        assert_eq!(res.image_url, expect.image_url);
    }

    #[test]
    fn test_invalid_get_size() {
        let invalid_sizes = JsonRootSizes {
            sizes: Sizes {
                size: vec![Size {
                    label: String::from("Small"),
                    source: String::from("url:small"),
                }],
            },
        };
        let dummy_id = "42";
        let res = JsonParser::parse_get_sizes(&invalid_sizes, dummy_id);
        let expect = ImageHosterError::ImageIsTooSmall;
        assert_eq!(expect, res.unwrap_err());
    }

    #[test]
    fn test_valid_check_license() {
        let valid_licenses = JsonRootLicense {
            license_history: vec![
                LicenceHistory {
                    date_change: 1_295_918_034,
                    new_license: String::from("Attribution License"),
                },
                LicenceHistory {
                    date_change: 1_598_990_519,
                    new_license: String::from("Public Domain Mark"),
                },
            ],
        };
        assert!(JsonParser::check_license(&valid_licenses));
    }

    #[test]
    fn test_valid_parse_error() {
        let valid_error = JsonRootError {
            stat: String::new(),
            code: 0,
            message: String::from("Sorry, the Flickr API service is not currently available."),
        };
        let res = JsonParser::parse_error(&valid_error);
        assert_eq!(res, ImageHosterError::ServiceUnavailable);
    }

    #[test]
    fn test_invalid_parse_error() {
        let invalid_error = JsonRootError {
            stat: String::new(),
            code: 42,
            message: String::from("HELP!"),
        };
        let res = JsonParser::parse_error(&invalid_error);
        assert_eq!(
            res,
            ImageHosterError::SomethingWentWrong(String::from("HELP!"))
        );
    }
}
