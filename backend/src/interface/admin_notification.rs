//! This interface allows administrators to be notified of reporting requests.

use async_trait::async_trait;

use crate::util::{ReportReason, Uuid};

/// Interface for notification of administrators.
#[async_trait]
pub trait AdminNotification: Sync + Send {
    /// Notifies an administrator about a newly reported image and the response automatically taken.
    async fn notify_admin_image_report(&self, info: ImageReportInfo);
}

#[derive(Debug)]
/// Structure containing all information about the reporting of an image.
pub struct ImageReportInfo {
    /// Reason for the report.
    pub reason: ReportReason,
    /// Whether the image got hidden automatically.
    pub image_got_hidden: bool,
    /// Identifier of the image used in the datastore.
    pub image_id: Uuid,
    /// URL to the image at the image hoster.
    pub image_link: String,
    /// Number of times this image was reported, including the current report.
    pub report_count: u32,
    /// Number of positive ratings for this image.
    pub positive_rating_count: u32,
    /// Number of negative ratings for this image.
    pub negative_rating_count: u32,
    /// Image rank after which the images are sorted when shown to the user.
    pub get_image_rank: f32,
}
