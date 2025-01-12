//! Module for preprocessing uploaded images

use image::{imageops::FilterType, DynamicImage, ImageError, ImageFormat, ImageReader};
use std::io::Cursor;
use thiserror::Error;

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

/// Structure containing all information necessary for image preprocessing.
#[derive(Debug, Clone, Copy)]
pub struct ImagePreprocessingInfo {
    /// Maximal width of images stored. Images get resized otherwise.
    pub max_image_width: u32,
    /// Maximal height of images stored. Images get resized otherwise.
    pub max_image_height: u32,
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
    pub fn preprocess_image(
        &self,
        image_data: Vec<u8>,
        image_type: Option<String>,
    ) -> Result<DynamicImage> {
        let max_width = self.max_width;
        let max_height = self.max_height;

        let mut reader = ImageReader::new(Cursor::new(image_data));
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
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_preprocess() {
        let image_file = include_bytes!("../tests/test.png").to_vec();

        let info = ImagePreprocessingInfo {
            max_image_height: 100,
            max_image_width: 100,
        };
        let preprocessor = ImagePreprocessor::new(info);

        let processed_image = preprocessor
            .preprocess_image(image_file, Some("image/png".into()))
            .expect("image should be processed");

        assert!(processed_image.width() <= 100);
        assert!(processed_image.height() <= 100);
    }
}
