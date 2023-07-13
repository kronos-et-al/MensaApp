use async_trait::async_trait;

use crate::interface::image_review::ImageReviewScheduling;

pub struct ImageReviewer;

#[async_trait]
impl ImageReviewScheduling for ImageReviewer {
    /// Start the image review process.
    async fn start_image_review(&self) {}
}
