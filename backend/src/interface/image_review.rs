//! This interface allows starting the process of checking the existence of images linked to meals.

use async_trait::async_trait;

/// This interface allows starting the image review process to check for deleted images at the image hoster.
#[async_trait]
pub trait ImageReviewScheduling: Send + Sync {
    /// Start the image review process.
    async fn start_image_review(&self);
}
