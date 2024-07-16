//! This interface is responsible for storing files.

use async_trait::async_trait;
use thiserror::Error;

use crate::util::{ImageResource, Uuid};

/// Result returned from file operations, potentially containing a [`ImageError`].
pub type Result<T> = std::result::Result<T, ImageError>;

/// This interface allows to store images as file.
#[async_trait]
pub trait ImageStorage: Send + Sync {
    /// Permanently saves an image with the given id.
    async fn save_image(&self, id: Uuid, image: ImageResource) -> Result<()>;
    /// Deletes an image resource.
    async fn delete_image(&self, id: Uuid) -> Result<()>;
}

/// Enum describing possible ways an file operation can go wrong.
#[derive(Debug, Error)]
pub enum ImageError {
    /// An error in the image processing library occurred.
    #[error("Error while image operation: {0}")]
    ImageError(#[from] image::ImageError),

    /// An error while io operation to an image.
    #[error("Error while image io operation: {0}")]
    IoError(#[from] tokio::io::Error),
}
