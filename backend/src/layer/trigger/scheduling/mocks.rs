//! This crate contains mocks of [`MensaParseScheduling`] and [`ImageReviewScheduling`] for testing.
#![cfg(test)]
use std::sync::{Arc, Mutex};

use async_trait::async_trait;
use tracing::debug;

use crate::interface::{
    image_review::ImageReviewScheduling, mealplan_management::MensaParseScheduling,
};

#[derive(Default, Clone)]
pub struct MensaParseMock {
    update_calls: Arc<Mutex<u32>>,
    full_calls: Arc<Mutex<u32>>,
}

impl MensaParseMock {
    /// A function to get the number of calls to the function of the same name
    ///
    /// # Panics
    /// if the mutex could not be acquired
    #[must_use]
    pub fn get_update_calls(&self) -> u32 {
        *self
            .update_calls
            .lock()
            .expect("failed to lock mutex for `update_calls` counter")
    }

    /// A function to get the number of calls to the function of the same name
    ///
    /// # Panics
    /// if the mutex could not be acquired
    #[must_use]
    pub fn get_full_calls(&self) -> u32 {
        *self
            .full_calls
            .lock()
            .expect("failed to lock mutex for `full_calls` counter")
    }
}

#[async_trait]
impl MensaParseScheduling for MensaParseMock {
    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals of the current date.
    async fn start_update_parsing(&self) {
        debug!("start_update_parsing");
        *self
            .update_calls
            .lock()
            .expect("failed to lock mutex for `update_calls` counter") += 1;

        return;
    }

    /// Initiate the parsing procedure of the canteen-website.
    /// Only parse meals for the next four weeks.
    async fn start_full_parsing(&self) {
        debug!("start_full_parsing");
        *self
            .full_calls
            .lock()
            .expect("failed to lock mutex for `full_calls` counter") += 1;
        return;
    }
}

#[derive(Default, Clone)]
pub struct ImageReviewMock {
    calls: Arc<Mutex<u32>>,
}

impl ImageReviewMock {
    /// A function to get the number of calls to the function of the same name
    ///
    /// # Panics
    /// if the mutex could not be acquired
    #[must_use]
    pub fn get_calls(&self) -> u32 {
        *self
            .calls
            .lock()
            .expect("failed to lock mutex for `calls` counter")
    }
}

#[async_trait]
impl ImageReviewScheduling for ImageReviewMock {
    /// Start the image review process.
    async fn start_image_review(&self) {
        // debug!("start_image_review");
        *self
            .calls
            .lock()
            .expect("failed to lock mutex for `calls` counter") += 1;
        return;
    }
}
