use serde::Deserialize;

/// Example for a valid `get_size` response structure:
//<sizes canblog="1" canprint="1" candownload="1">
//  <size label="Square" width="75" height="75" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_s.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/sq/" media="photo" />
//  <size label="Large Square" width="150" height="150" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_q.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/q/" media="photo" />
//  <size label="Thumbnail" width="100" height="75" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_t.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/t/" media="photo" />
//  <size label="Small" width="240" height="180" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_m.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/s/" media="photo" />
//  <size label="Small 320" width="320" height="240" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_n.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/n/" media="photo" />
//  <size label="Medium" width="500" height="375" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/m/" media="photo" />
//  <size label="Medium 640" width="640" height="480" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_z.jpg?zz=1" url="http://www.flickr.com/photos/stewart/567229075/sizes/z/" media="photo" />
//  <size label="Medium 800" width="800" height="600" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_c.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/c/" media="photo" />
//  <size label="Large" width="1024" height="768" source="http://farm2.staticflickr.com/1103/567229075_2cf8456f01_b.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/l/" media="photo" />
//  <size label="Original" width="2400" height="1800" source="http://farm2.staticflickr.com/1103/567229075_6dc09dc6da_o.jpg" url="http://www.flickr.com/photos/stewart/567229075/sizes/o/" media="photo" />
//</sizes>

#[derive(Debug, Deserialize)]
pub struct JsonRootSizes {
    pub sizes: Sizes,
}
#[derive(Debug, Deserialize)]
pub struct Sizes {
    pub size: Vec<Size>
}
#[derive(Debug, Deserialize, Clone)]
pub struct Size {
    pub label: String,
    pub width: u32, // TODO not needed for now
    pub height: u32, // TODO not needed for now
    pub source: String
}

/// Example for a valid `get_license` response structure:
//<rsp stat="ok">
//  <license_history date_change="1295918034" old_license="All Rights Reserved" old_license_url="" new_license="Attribution License" new_license_url="https://creativecommons.org/licenses/by/2.0/" />
//  <license_history date_change="1598990519" old_license="Attribution License" old_license_url="https://creativecommons.org/licenses/by/2.0/" new_license="All Rights Reserved" new_license_url="" />
//</rsp>

#[derive(Debug, Deserialize)]
pub struct JsonRootLicense {
    pub rsp: LicenseRsp
}
#[derive(Debug, Deserialize)]
pub struct LicenseRsp {
    pub license_history: Vec<LicenceHistory>
}
#[derive(Debug, Deserialize, Clone)]
pub struct LicenceHistory {
    pub date_change: u64,
    pub old_license: String, // TODO not needed for now
    pub new_license: String
}

/// Example for an error response structure:
//<rsp stat="fail">
// 	<err code="0" msg="Sorry, the Flickr API service is not currently available." />
//</rsp>

#[derive(Debug, Deserialize)]
pub struct JsonRootError {
    pub rsp: ErrRsp
}
#[derive(Debug, Deserialize)]
pub struct ErrRsp {
    pub err: Err
}
#[derive(Debug, Deserialize)]
pub struct Err {
    pub code: u32,
    pub msg: String
}