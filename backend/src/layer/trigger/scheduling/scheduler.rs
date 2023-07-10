use std::{net::Shutdown, sync::Arc};

use crate::interface::{
    image_review::{self, ImageReviewScheduling},
    mealplan_management::MensaParseScheduling,
};

use tokio::sync::Notify;
use tokio_cron_scheduler::{Job, JobScheduler, JobToRun};

/// Structure containing [cron](https://cron.help/) schedules for running actions regularly.
pub struct ScheduleInfo {
    /// Cron schedule for running the image review process to check for no longer existing images, see [`ImageReviewScheduling`].
    pub image_review_schedule: String,
    /// Cron schedule for running the meal plan update process for the current day's meal plan, see [`MensaParseScheduling`].
    pub update_parse_schedule: String,
    /// Cron schedule for running the meal plan update process for all available meal plan data, see [`MensaParseScheduling`].
    pub full_parse_schedule: String,
}

/// Class fro planning regular events.
pub struct Scheduler {
    scheduler: JobScheduler,
}

impl Scheduler {
    /// Creates a new scheduler with time plans specified in `info` and actions specified in the `scheduling`s.
    pub async fn new(
        info: ScheduleInfo,
        image_scheduling: impl ImageReviewScheduling + 'static,
        parse_scheduling: impl MensaParseScheduling + 'static,
    ) -> Self {
        let scheduler = JobScheduler::new()
            .await
            .expect("cannot initialize scheduler");

        let image_review = Arc::new(image_scheduling);

        let image_review_job =
            Job::new_cron_job_async(info.image_review_schedule.as_ref(), move |_, _| {
                let image_review = image_review.clone();
                Box::pin(async move {
                    image_review.start_image_review().await;
                })
            })
            .expect("could not create schedule for image reviewing");

        scheduler
            .add(image_review_job)
            .await
            .expect("could not add job for image reviewing to scheduler");

        Self { scheduler }
    }

    /// Starts the scheduler. It runs in the background until it is stopped with [`Self::shutdown()`].
    pub async fn start(&self) {
        self.scheduler
            .start()
            .await
            .expect("scheduler should run properly");
    }

    /// Stops the scheduler.
    pub async fn shutdown(&mut self) {
        let shutdown_finished = Arc::new(Notify::new());

        let shutdown_sender = shutdown_finished.clone();
        self.scheduler.set_shutdown_handler(Box::new(move || {
            let shutdown_sender = shutdown_sender.clone();
            Box::pin(async move { shutdown_sender.notify_waiters() })
        }));

        self.scheduler
            .shutdown()
            .await
            .expect("could not shutdown scheduler");

        // wait until shutdown finished
        shutdown_finished.notified().await;
    }
}
