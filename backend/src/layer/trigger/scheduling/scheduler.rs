//! Module containing the scheduler to schedule regular actions.
use std::{sync::Arc, time::Instant};

use crate::interface::mealplan_management::MensaParseScheduling;

use tokio::sync::Notify;
use tokio_cron_scheduler::{Job, JobScheduler};
use tracing::{info, info_span, Instrument};

/// Structure containing [cron](https://cron.help/)-like schedules for running actions regularly.
///
/// **Important:** Unlike regular cron expressions, seconds also have to be specified, see [here](https://lib.rs/crates/tokio-cron-scheduler).
pub struct ScheduleInfo {
    /// Cron-like schedule for running the meal plan update process for the current day's meal plan, see [`MensaParseScheduling`].
    pub update_parse_schedule: String,
    /// Cron-like schedule for running the meal plan update process for all available meal plan data, see [`MensaParseScheduling`].
    pub full_parse_schedule: String,
}

#[derive(PartialEq, Eq, Debug)]
enum State {
    Created,
    Running,
    Stopped,
}

/// Class fro planning regular events.
pub struct Scheduler {
    scheduler: JobScheduler,
    state: State,
}

impl Scheduler {
    /// Creates a new scheduler with time plans specified in `info` and actions specified in the `scheduling`s.
    ///
    /// # Panics
    /// 1. If the scheduler could not be initialised
    /// 2. If the schedules could not be created (invalid cron syntax)
    /// 3. If the jobs could not be scheduled
    pub async fn new(
        info: ScheduleInfo,
        parse_scheduling: impl MensaParseScheduling + 'static,
    ) -> Self {
        let scheduler = JobScheduler::new()
            .await
            .expect("cannot initialize scheduler");

        // === mensa parsing ===

        let mensa_parse = Arc::new(parse_scheduling);
        let timezone = chrono::Local::now().timezone();

        // mensa update parsing
        let mensa_parse_update = mensa_parse.clone();
        let update_parse_job = Job::new_async_tz(
            &info.update_parse_schedule,
            timezone,
            move |_, _| {
                let mensa_parse = mensa_parse_update.clone();
                Box::pin(
                    async move {
                        info!("Started mensa update parsing.");
                        let start: Instant = Instant::now();

                        mensa_parse.start_update_parsing().await;

                        info!("Finished mensa update parsing in {:?}.", start.elapsed());
                    }
                    .instrument(info_span!("update_parsing")),
                )
            },
        )
        .expect("could not create schedule for image reviewing");

        scheduler
            .add(update_parse_job)
            .await
            .expect("could not add job for update parsing to scheduler");

        // mensa full parsing
        let full_parse_job =
            Job::new_async_tz(&info.full_parse_schedule, timezone, move |_, _| {
                let mensa_parse = mensa_parse.clone();
                Box::pin(
                    async move {
                        info!("Started mensa full parsing.");
                        let start: Instant = Instant::now();

                        mensa_parse.start_full_parsing().await;

                        info!("Finished mensa full parsing in {:?}.", start.elapsed());
                    }
                    .instrument(info_span!("full_parsing")),
                )
            })
            .expect("could not create schedule for image reviewing");

        scheduler
            .add(full_parse_job)
            .await
            .expect("could not add job for full parsing to scheduler");

        Self {
            scheduler,
            state: State::Created,
        }
    }

    /// Starts the scheduler. It runs in the background until it is stopped with [`Self::shutdown()`].
    ///
    /// # Panics
    /// Panics if called when already running or stoppen.
    pub async fn start(&mut self) {
        assert_eq!(
            self.state,
            State::Created,
            "scheduler should only be started once"
        );
        self.scheduler
            .start()
            .await
            .expect("scheduler should only be started once");
        self.state = State::Running;
        info!("Started scheduler.");
    }

    /// Stops the scheduler.
    ///
    /// # Panics
    /// Panics if called when not running.
    pub async fn shutdown(&mut self) {
        assert_eq!(
            self.state,
            State::Running,
            "scheduler should be started and not shut down"
        );
        let shutdown_finished = Arc::new(Notify::new());

        let shutdown_sender = shutdown_finished.clone();
        self.scheduler.set_shutdown_handler(Box::new(move || {
            let shutdown_sender = shutdown_sender.clone();
            Box::pin(async move { shutdown_sender.notify_one() })
        }));

        self.scheduler
            .shutdown()
            .await
            .expect("could not shut down scheduler");

        // wait until shutdown finished
        shutdown_finished.notified().await;
        self.state = State::Stopped;
        info!("Scheduler shutdown complete.");
    }
}

#[cfg(test)]
mod tests {
    use std::time::Duration;

    use crate::layer::trigger::scheduling::mocks::MensaParseMock;

    use super::*;
    #[tokio::test]
    async fn test_scheduling() {
        let info = ScheduleInfo {
            full_parse_schedule: "*/1 * * * * *".into(),
            update_parse_schedule: "*/2 * * * * *".into(),
        };
        let mensa_parser = MensaParseMock::default();

        let mut scheduler = Scheduler::new(info, mensa_parser.clone()).await;

        scheduler.start().await;

        tokio::time::sleep(Duration::from_secs(10)).await;

        println!("shutting down");
        scheduler.shutdown().await;

        assert!(
            (9..=10).contains(&mensa_parser.get_full_calls()),
            "full parse was not called right amount"
        );
        assert!(
            (4..=5).contains(&mensa_parser.get_update_calls()),
            "update parse was not called right amount"
        );
    }

    #[tokio::test]
    #[should_panic = "scheduler should only be started once"]
    async fn test_double_start() {
        let info = ScheduleInfo {
            full_parse_schedule: "*/1 * * * * *".into(),
            update_parse_schedule: "*/2 * * * * *".into(),
        };
        let mensa_parser = MensaParseMock::default();

        let mut scheduler = Scheduler::new(info, mensa_parser.clone()).await;
        scheduler.start().await;
        scheduler.start().await;
        scheduler.shutdown().await;
    }

    #[tokio::test]
    #[should_panic = "scheduler should be started and not shut down"]
    async fn test_not_running() {
        let info = ScheduleInfo {
            full_parse_schedule: "*/1 * * * * *".into(),
            update_parse_schedule: "*/2 * * * * *".into(),
        };
        let mensa_parser = MensaParseMock::default();

        let mut scheduler = Scheduler::new(info, mensa_parser.clone()).await;
        scheduler.shutdown().await;
    }
}
