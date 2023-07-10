//! This crate contains mocks of [`MensaParseScheduling`] and [`ImageReviewScheduling`] for testing.
#![cfg(test)]
use std::sync::{Arc, Mutex};

use async_trait::async_trait;
use tracing::info;

use crate::interface::{
    image_review::ImageReviewScheduling, mealplan_management::MensaParseScheduling,
};

#[derive(Default, Clone)]
pub struct MensaParseMock {
    update_calls: Arc<Mutex<u32>>,
    full_calls: Arc<Mutex<u32>>,
}

impl MensaParseMock {
    pub fn get_update_calls(&self) -> u32 {
        *self.update_calls.lock().unwrap()
    }
    pub fn get_full_calls(&self) -> u32 {
        *self.full_calls.lock().unwrap()
    }
}


#[async_trait]
impl MensaParseScheduling for MensaParseMock {
    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals of the current date.
    async fn start_update_parsing(&self) {
        info!("start_update_parsing");
        *self.update_calls.lock().unwrap() += 1;

        return;
    }

    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals for the next four weeks.
    async fn start_full_parsing(&self) {
        info!("start_full_parsing");
        *self.full_calls.lock().unwrap() += 1;
        return;
    }
}

#[derive(Default, Clone)]
pub struct ImageReviewMock {
    calls: Arc<Mutex<u32>>,
}

impl ImageReviewMock {
    pub fn get_calls(&self) -> u32 {
        *self.calls.lock().unwrap()
    }
}

#[async_trait]
impl ImageReviewScheduling for ImageReviewMock {
    /// Start the image review process.
    async fn start_image_review(&self) {
        info!("start_image_review");
        *self.calls.lock().unwrap() += 1;
        return;
    }
}
