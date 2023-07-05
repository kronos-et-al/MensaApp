//! This crate contains mocks of [`MensaParseScheduling`] and [`ImageReviewScheduling`] for testing.

use async_trait::async_trait;

use crate::interface::{mealplan_management::MensaParseScheduling, image_review::ImageReviewScheduling};

pub struct MensaParseMock;

#[async_trait]
impl MensaParseScheduling for MensaParseMock {
    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals of the current date.
    async fn start_update_parsing() {
        return;
    }

    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals for the next four weeks.
    async fn start_full_parsing() {
        return;
    }
}

pub struct ImageReviewMock;

#[async_trait]
impl ImageReviewScheduling for ImageReviewMock {
    /// Start the image review process.
    async fn start_image_review() {
        return;
    }
}