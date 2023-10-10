//! Module for preprocessing uploaded images

use image::{imageops::FilterType, io::Reader, DynamicImage, ImageError, ImageFormat};
use std::io::BufReader;
use thiserror::Error;
use tokio::fs::File;

pub type Result<T> = std::result::Result<T, ImagePreprocessingError>;

#[derive(Error, Debug)]
pub enum ImagePreprocessingError {
    #[error("Error guessing image format: {0}")]
    FormatGuessError(std::io::Error),
    #[error("Error during image operation:{0}")]
    ImageError(#[from] ImageError),
}

/// Class for preprocessing uploaded images.
#[derive(Debug)]
pub struct ImagePreprocessor {
    max_width: u32,
    max_height: u32,
}

impl ImagePreprocessor {
    pub fn new(max_width: u32, max_height: u32) -> Self {
        Self {
            max_width,
            max_height,
        }
    }

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
                reader.set_format(format)
            } else {
                reader = reader
                    .with_guessed_format()
                    .map_err(ImagePreprocessingError::FormatGuessError)?;
            }

            // read image
            let image = reader.decode()?;

            // downscale
            if image.width() > max_width || image.height() > max_height {
                image.resize(max_width, max_height, FilterType::Triangle);
            }
            Ok(image)
        })
        .await
        .expect("image preprocessing should not panic nor get aborted")
    }
}
