use async_trait::async_trait;

use crate::{
    interface::admin_notification::{AdminNotification, ImageReportInfo},
    startup::config::mail_info::MailInfo,
};

pub struct MailSender {
    config: MailInfo,
}

impl MailSender {
    #[must_use]
    pub const fn new(config: MailInfo) -> Self {
        Self { config }
    }
}

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        todo!()
    }
}
