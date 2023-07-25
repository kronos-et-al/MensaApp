//! These structs are used for image hoster data.

/// Struct contains information all necessary information that the image hoster provides.
#[derive(Debug)]
pub struct ImageMetaData {
    /// The image hoster image identification.
    pub id: String,
    /// The url which short links to the image. Different to the url provided by an user.
    pub image_url: String,
}
