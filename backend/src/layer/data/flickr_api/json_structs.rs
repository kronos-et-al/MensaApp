use serde::Deserialize;

/// Example for a valid `get_size` response structure:
/// ```json
///{
///     "sizes": {
///         "canblog": 0,
///         "canprint": 0,
///         "candownload": 0,
///         "size": [
///             {
///                 "label": "Square",
///                 "width": 75,
///                 "height": 75,
///                 "source": "https:\/\/live.staticflickr.com\/65535\/52310534489_41350164c9_s.jpg",
///                 "url": "https:\/\/www.flickr.com\/photos\/gerdavs\/52310534489\/sizes\/sq\/",
///                 "media": "photo"
///             },
///             {
///                 "label": "Large Square",
///                 "width": 150,
///                 "height": 150,
///                 "source": "https:\/\/live.staticflickr.com\/65535\/52310534489_41350164c9_q.jpg",
///                 "url": "https:\/\/www.flickr.com\/photos\/gerdavs\/52310534489\/sizes\/q\/",
///                 "media": "photo"
///             }
///         ]
///     },
///     "stat": "ok"
///}
/// ```

#[derive(Debug, Deserialize)]
pub struct JsonRootSizes {
    pub sizes: Sizes,
}
#[derive(Debug, Deserialize)]
pub struct Sizes {
    pub size: Vec<Size>,
}
#[derive(Debug, Deserialize, Clone)]
pub struct Size {
    pub label: String,
    pub source: String,
}

/// Example for a valid `get_license` response structure:
/// ```json
///{
///     "license_history": [
///         {
///             "date_change": 1661436555,
///             "old_license": "All Rights Reserved",
///             "old_license_url": "",
///             "new_license": "",
///             "new_license_url": ""
///         }
///     ],
///     "stat": "ok"
/// }
///  ```

#[derive(Debug, Deserialize)]
pub struct JsonRootLicense {
    pub license_history: Vec<LicenceHistory>,
}
#[derive(Debug, Deserialize, Clone)]
pub struct LicenceHistory {
    pub date_change: u64,
    pub new_license: String,
}

/// Example for an error response structure:
/// ```json
///{
///     "stat": "fail",
///     "code": 0,
///     "message": "Sorry, the Flickr API service is not currently available."
///}
/// ```

#[derive(Debug, Deserialize)]
pub struct JsonRootError {
    pub stat: String,
    pub code: u32,
    pub message: String,
}
