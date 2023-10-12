//! Module for preprocessing uploaded images

use image::{imageops::FilterType, io::Reader, DynamicImage, ImageError, ImageFormat};
use std::io::BufReader;
use thiserror::Error;
use tokio::fs::File;

use super::command_handler::ImagePreprocessingInfo;

/// Result returned on image preprocessing operations.
pub type Result<T> = std::result::Result<T, ImagePreprocessingError>;

/// Enum describing possible ways the image preprocessing can fail.
#[derive(Error, Debug)]
pub enum ImagePreprocessingError {
    /// Error occurring when the image format could not be guessed out of the data and no mime type was provided.
    #[error("Error guessing image format: {0}")]
    FormatGuessError(std::io::Error),
    /// Error occurring wile operating on the image.
    #[error("Error during image operation: {0}")]
    ImageError(#[from] ImageError),
}

/// Class for preprocessing uploaded images.
#[derive(Debug)]
pub struct ImagePreprocessor {
    max_width: u32,
    max_height: u32,
}

impl ImagePreprocessor {
    /// Creates a new instance.
    #[must_use]
    pub const fn new(info: ImagePreprocessingInfo) -> Self {
        Self {
            max_width: info.max_image_width,
            max_height: info.max_image_height,
        }
    }

    /// Pre-process the given file to an image by reading and then down scaling it if to large.
    /// # Panics
    /// Should never panic.
    /// # Errors
    /// - Image type was not provided and could not be guessed
    /// - Image could not be decoded from file
    pub async fn preprocess_image(
        &self,
        file: File,
        image_type: Option<String>,
    ) -> Result<DynamicImage> {
        let max_width = self.max_width;
        let max_height = self.max_height;
        let file = file.into_std().await;

        tokio::task::spawn_blocking(move || {
            let mut reader = Reader::new(BufReader::new(file));
            if let Some(format) = image_type.and_then(ImageFormat::from_mime_type) {
                reader.set_format(format);
            } else {
                reader = reader
                    .with_guessed_format()
                    .map_err(ImagePreprocessingError::FormatGuessError)?;
            }

            // read image
            let image = reader.decode()?;

            // downscale
            if image.width() > max_width || image.height() > max_height {
                let resized = image.resize(max_width, max_height, FilterType::Triangle);
                Ok(resized)
            } else {
                Ok(image)
            }
        })
        .await
        .expect("image preprocessing should not panic nor get aborted")
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[tokio::test]
    async fn test_preprocess() {
        let dir = tempfile::tempdir().expect("tempdir should be accessible");
        let mut png_path = dir.path().to_path_buf();
        png_path.push("test.png");
        tokio::fs::write(&png_path, include_bytes!("../tests/test.png"))
            .await
            .expect("image should be saved");

        let image_file = tokio::fs::File::open(&png_path)
            .await
            .expect("saved file should be opened");

        let info = ImagePreprocessingInfo {
            max_image_height: 100,
            max_image_width: 100,
        };
        let preprocessor = ImagePreprocessor::new(info);

        let processed_image = preprocessor
            .preprocess_image(image_file, Some("image/png".into()))
            .await
            .expect("image should be processed");

        assert!(processed_image.width() <= 100);
        assert!(processed_image.height() <= 100);
    }
}
