//! See [`FileHandler`].

use std::path::PathBuf;

use crate::util::IMAGE_EXTENSION;

use async_trait::async_trait;
use tracing::trace;

use crate::{
    interface::image_storage::{ImageStorage, Result},
    util::{ImageResource, Uuid},
};

/// Struct containing all information necessary to construct a [`FileHandler`].
pub struct FileHandlerInfo {
    /// Path where images should be stored
    pub image_path: PathBuf,
}

/// Class for saving images to the file system.
pub struct FileHandler {
    image_path: PathBuf,
}

impl FileHandler {
    #[must_use]
    pub fn new(info: FileHandlerInfo) -> Self {
        Self {
            image_path: info.image_path,
        }
    }
}

#[async_trait]
impl ImageStorage for FileHandler {
    async fn save_image(&self, id: Uuid, image: ImageResource) -> Result<()> {
        let mut file_path = self.image_path.clone();
        file_path.push(id.to_string());
        file_path.set_extension(IMAGE_EXTENSION);

        let file_path_string = file_path.display().to_string();

        tokio::task::spawn_blocking(move || image.save(file_path))
            .await
            .expect("image saving should not panic nor get aborted")?;

        trace!(path = file_path_string, "Saved image {id}");

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use image::ImageBuffer;
    use tempfile::TempDir;

    use super::*;
    use crate::util::ImageResource;

    #[tokio::test]
    async fn test_save_image() {
        let image =
            ImageResource::ImageRgb8(ImageBuffer::from_fn(10, 10, |_, _| image::Rgb([10; 3])));

        let uuid = Uuid::new_v4();

        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path();
        println!("saving to: {}", path.display());

        let info = FileHandlerInfo {
            image_path: path.to_path_buf(),
        };

        let file_handler = FileHandler::new(info);

        file_handler.save_image(uuid, image.clone()).await.unwrap();

        let mut image_path = path.to_path_buf();
        image_path.push(uuid.to_string());
        image_path.set_extension(IMAGE_EXTENSION);

        let read_image = image::io::Reader::open(image_path)
            .unwrap()
            .decode()
            .unwrap();

        assert_eq!(image, read_image); // this only works for very basic (like monotone) images due to JPEG compression.
    }
}
