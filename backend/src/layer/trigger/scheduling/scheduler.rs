use std::sync::Arc;

use crate::interface::{
    image_review::ImageReviewScheduling, mealplan_management::MensaParseScheduling,
};

use tokio::sync::Notify;
use tokio_cron_scheduler::{Job, JobScheduler};
use tracing::info;

/// Structure containing [cron](https://cron.help/)-like schedules for running actions regularly.
///
/// **Important:** Unlike regular cron expressions, seconds also have to be specified, see [here](https://lib.rs/crates/tokio-cron-scheduler).
pub struct ScheduleInfo {
    /// Cron-like schedule for running the image review process to check for no longer existing images, see [`ImageReviewScheduling`].
    pub image_review_schedule: String,
    /// Cron-like schedule for running the meal plan update process for the current day's meal plan, see [`MensaParseScheduling`].
    pub update_parse_schedule: String,
    /// Cron-like schedule for running the meal plan update process for all available meal plan data, see [`MensaParseScheduling`].
    pub full_parse_schedule: String,
}

/// Class fro planning regular events.
pub struct Scheduler {
    scheduler: JobScheduler,
}

impl Scheduler {
    // TODO error handeling
    /// Creates a new scheduler with time plans specified in `info` and actions specified in the `scheduling`s.
    pub async fn new(
        info: ScheduleInfo,
        image_scheduling: impl ImageReviewScheduling + 'static,
        parse_scheduling: impl MensaParseScheduling + 'static,
    ) -> Self {
        let scheduler = JobScheduler::new()
            .await
            .expect("cannot initialize scheduler");

        // === image review ===
        let image_review = Arc::new(image_scheduling);
        // TODO add tracing spans

        let image_review_job =
            Job::new_async(info.image_review_schedule.as_ref(), move |_, _| {
                let image_review = image_review.clone();
                Box::pin(async move {
                    image_review.start_image_review().await;
                })
            })
            .expect("could not create schedule for image reviewing, you should also specify seconds in your cron expression");

        scheduler
            .add(image_review_job)
            .await
            .expect("could not add job for image reviewing to scheduler");

        // === mensa parsing ===
        let mensa_parse = Arc::new(parse_scheduling);
        // mensa update parsing
        let mensa_parse_update = mensa_parse.clone();
        let update_parse_job = Job::new_async(info.update_parse_schedule.as_ref(), move |_, _| {
            let mensa_parse = mensa_parse_update.clone();
            Box::pin(async move {
                mensa_parse.start_update_parsing().await;
            })
        })
        .expect("could not create schedule for image reviewing");

        scheduler
            .add(update_parse_job)
            .await
            .expect("could not add job for update parsing to scheduler");

        // mensa full parsing
        let full_parse_job = Job::new_async(info.full_parse_schedule.as_ref(), move |_, _| {
            let mensa_parse = mensa_parse.clone();
            Box::pin(async move {
                mensa_parse.start_full_parsing().await;
            })
        })
        .expect("could not create schedule for image reviewing");

        scheduler
            .add(full_parse_job)
            .await
            .expect("could not add job for full parsing to scheduler");

        Self { scheduler }
    }

    /// Starts the scheduler. It runs in the background until it is stopped with [`Self::shutdown()`].
    pub async fn start(&self) {
        self.scheduler
            .start()
            .await
            .expect("scheduler should run properly");
        info!("Started scheduler.");
    }

    /// Stops the scheduler.
    pub async fn shutdown(&mut self) {
        let shutdown_finished = Arc::new(Notify::new());

        let shutdown_sender = shutdown_finished.clone();
        self.scheduler.set_shutdown_handler(Box::new(move || {
            let shutdown_sender = shutdown_sender.clone();
            Box::pin(async move { shutdown_sender.notify_one() })
        }));

        self.scheduler
            .shutdown()
            .await
            .expect("could not shutdown scheduler");

        // wait until shutdown finished
        shutdown_finished.notified().await;
        info!("Scheduler shutdown complete.");
    }
}

#[cfg(test)]
mod tests {
    use std::time::Duration;

    use crate::layer::trigger::scheduling::mocks::{ImageReviewMock, MensaParseMock};

    use super::*;
    use tracing::Level;

    #[tokio::test]
    async fn test_a() {
        let subscriber = tracing_subscriber::FmtSubscriber::builder()
            .with_max_level(Level::TRACE)
            .finish();
        tracing::subscriber::set_global_default(subscriber)
            .expect("Setting default subscriber failed");

        let info = ScheduleInfo {
            full_parse_schedule: "*/1 * * * * *".into(),
            update_parse_schedule: "*/2 * * * * *".into(),
            image_review_schedule: "*/5 * * * * *".into(),
        };
        let mensa_parser = MensaParseMock::default();
        let image_parser = ImageReviewMock::default();
        
        let mut scheduler = Scheduler::new(info, image_parser.clone(), mensa_parser.clone()).await;

        scheduler.start().await;

        tokio::time::sleep(Duration::from_secs(10)).await;

        info!("shutting down");
        scheduler.shutdown().await;

        assert_eq!(10, mensa_parser.get_full_calls(), "full parse was not called right amount");
        assert_eq!(5, mensa_parser.get_update_calls(), "update parse was not called right amount");
        assert_eq!(2, image_parser.get_calls(), "image review was not called right amount");
    }
}
