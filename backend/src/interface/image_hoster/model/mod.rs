//! These structs are used for image hoster data

/// This struct contains all information about an error that can occur by the image hoster api.
pub struct ImageHosterError {
    /// Code of the error.
    code: u32,
    /// A more detailed description of the error.
    message: String
}

/// Struct contains information all necessary information that the image hoster provides.
pub struct ImageMetaData {
    /// The image hoster image identification.
    id: String,
    /// The url which short links to the image. Different to the url provided by an user.
    image_url: String,
    /// The licence of the image.
    licence: String
}
