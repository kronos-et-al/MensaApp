use scraper::{ElementRef, Html, Selector};
use crate::interface::image_hoster::ImageHosterError;
use crate::interface::image_hoster::model::ImageMetaData;

pub struct XMLParser;

// GET_SIZE SAMPLE
//<sizes canblog="1" canprint="1" candownload="1">
//   <size label="Square" width="75" height="75" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_s.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/sq/" media="photo" />
//   <size label="Large Square" width="150" height="150" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_q.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/q/" media="photo" />
//   <size label="Thumbnail" width="100" height="75" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_t.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/t/" media="photo" />
//   <size label="Small" width="240" height="180" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_m.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/s/" media="photo" />
//   <size label="Small 320" width="320" height="240" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_n.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/n/" media="photo" />
//   <size label="Medium" width="500" height="375" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/m/" media="photo" />
//   <size label="Medium 640" width="640" height="480" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_z.jpg?zz=1" url="http://www.flickr.com/photos/stewart/567229075/sizes/z/" media="photo" />
//   <size label="Medium 800" width="800" height="600" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_c.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/c/" media="photo" />
//   <size label="Large" width="1024" height="768" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_b.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/l/" media="photo" />
//   <size label="Original" width="2400" height="1800" source="http://farm2.staticflickr.com/1103/567229075_6dc09dc6da_o.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/o/" media="photo" />
// </sizes>

// GET_LICENCE_HISTORY SAMPLE
// <rsp stat="ok">
//   <license_history date_change="1295918034" old_license="All Rights Reserved" old_license_url="" new_license="Attribution License" new_license_url="https://creativecommons.org/licenses/by/2.0/" />
//   <license_history date_change="1598990519" old_license="Attribution License" old_license_url="https://creativecommons.org/licenses/by/2.0/" new_license="All Rights Reserved" new_license_url="" />
// </rsp>

// ERROR SAMPLE
// <?xml version="1.0" encoding="utf-8" ?>
// <rsp stat="fail">
// 	<err code="0" msg="Sorry, the Flickr API service is not currently available." />
// </rsp>



const SIZE_LABEL_SELECTOR: &str = r#"size label="Medium 800""#;
const SELECTED_TAG: &str = "source";

// TODO Define selectors for licence determination

// TODO Define error selectors

impl XMLParser {
    pub const fn new() -> Self {
        Self
    }

    pub fn parse_to_image(&self, xml: String, photo_id: String, licence: String) -> ImageMetaData {
        let document = Html::parse_fragment(&xml);
        let preferred_size_tag = Selector::parse(SIZE_LABEL_SELECTOR).map_err(|e| ImageHosterError::DecodeFailed(e.to_string()))?;
        let input = match document.select(&preferred_size_tag).next() {
            None => Err(ImageHosterError::DecodeFailed(e.to_string())),
            Some(input) => input
        };
        let image_url = input.value().attr(SELECTED_TAG);

        ImageMetaData {
            id: photo_id,
            image_url,
            licence
        };
        todo!()
    }

    pub fn get_licence(&self, xml: String) -> String {
        todo!()
    }

    pub fn map_image_hoster_error(&self, err_code: u32, err_info: String) -> ImageHosterError {
        match err_code {
            1 => ImageHosterError::PhotoNotFound,
            2 => ImageHosterError::PermissionDenied,
            100 => ImageHosterError::InvalidApiKey,
            0 => ImageHosterError::ServiceUnavailable,
            105 => ImageHosterError::ServiceUnavailable,
            111 => ImageHosterError::FormatNotFound(err_info),
            112 => ImageHosterError::FormatNotFound(err_info),
            _ => ImageHosterError::SomethingWentWrong(err_info)
        }
    }
}