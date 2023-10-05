//! This interface is responsible for storing files.

use async_trait::async_trait;
use thiserror::Error;

use crate::util::{ImageResource, Uuid};

pub type Result<T> = std::result::Result<T, ImageError>;

/// This interface allows to store images as file.
#[async_trait]
pub trait ImageStorage: Send + Sync {
    /// Permanently saves an image with the given id.
    async fn save_image(&self, id: Uuid, image: ImageResource) -> Result<()>;
}

/// Enum describing possible ways an file operation can go wrong.
#[derive(Debug, Error)]
pub enum ImageError {
    /// An error in the image processing library occurred.
    #[error("Error while image operation: {0}")]
    ImageError(#[from] image::ImageError),
}
