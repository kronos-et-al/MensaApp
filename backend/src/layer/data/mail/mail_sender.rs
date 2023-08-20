use async_trait::async_trait;
use thiserror::Error;

use lettre::{
    address::AddressError, message::Mailbox, transport::smtp::authentication::Credentials, Address,
    Message, SmtpTransport, Transport,
};

use crate::{
    interface::admin_notification::{AdminNotification, ImageReportInfo},
    layer::data::mail::mail_info::MailInfo,
};

use string_template::Template;
use tracing::{info, warn};

pub type MailResult<T> = std::result::Result<T, MailError>;

const REPORT_TEMPLATE: &str = include_str!("./template.txt");
const SENDER_NAME: &str = "MensaKa";
const RECEIVER_NAME: &str = "Administrator";
const MAIL_SUBJECT: &str = "An image was reported and requires your review";

/// Enum describing the possible ways, the mail notification can fail.
#[derive(Debug, Error)]
pub enum MailError {
    #[error("an error occurred while parsing the addresses: {0}")]
    AddressError(#[from] AddressError),
    #[error("an error occurred while reading the template: {0}")]
    TemplateError(#[from] std::io::Error),
    #[error("an error occurred while parsing the mail: {0}")]
    MailParseError(#[from] lettre::error::Error),
    #[error("an error occurred while sending the mail: {0}")]
    MailSendError(#[from] lettre::transport::smtp::Error),
}

pub struct MailSender {
    config: MailInfo,
    mailer: SmtpTransport,
}

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        if let Err(error) = self.try_notify_admin_image_report(&info) {
            warn!("Error notifying administrator: {error}");
        }
    }
}

impl MailSender {
    /// Creates a new [`MailSender`] with the attributes defined in config. Also creates an SMTP connection to the smtp server defined in config
    ///
    /// # Errors
    /// Returns an error, if the connection could not be established to the smtp server
    pub fn new(config: MailInfo) -> MailResult<Self> {
        let creds = Credentials::new(config.username.clone(), config.password.clone());
        let transport_builder = SmtpTransport::relay(&config.smtp_server)?;
        let mailer = transport_builder
            .port(config.smtp_port)
            .credentials(creds)
            .build();
        Ok(Self { config, mailer })
    }

    fn try_notify_admin_image_report(&self, info: &ImageReportInfo) -> MailResult<()> {
        let sender = self.get_sender()?;
        let reciever = self.get_receiver()?;
        let report = Self::get_report(info);
        let email = Message::builder()
            .from(sender)
            .to(reciever)
            .subject(MAIL_SUBJECT)
            .body(report)?;
        self.mailer.send(&email)?;
        info!(
            ?info,
            "Notified administrators about image report for image with id {}", info.image_id,
        );
        Ok(())
    }

    fn get_sender(&self) -> MailResult<Mailbox> {
        let address = self.config.username.parse::<Address>()?;
        Ok(Mailbox::new(Some(SENDER_NAME.to_string()), address))
    }

    fn get_receiver(&self) -> MailResult<Mailbox> {
        let address = self.config.admin_email_address.parse::<Address>()?;
        Ok(Mailbox::new(Some(RECEIVER_NAME.to_string()), address))
    }

    fn get_report(info: &ImageReportInfo) -> String {
        let info_array_map = [
            ("image_link", &info.image_link as &dyn ToString),
            ("image_id", &info.image_id),
            ("report_count", &info.report_count),
            ("reason", &info.reason),
            ("image_got_hidden", &info.image_got_hidden),
            ("positive_rating_count", &info.positive_rating_count),
            ("negative_rating_count", &info.negative_rating_count),
            ("get_image_rank", &info.get_image_rank),
            ("report_barrier", &info.report_barrier),
        ];

        let info_map = info_array_map
            .into_iter()
            .map(|(k, v)| (k, v.to_string()))
            .collect::<Vec<_>>();
        let info_map = info_map.iter().map(|(k, v)| (*k, v.as_str())).collect();

        Template::new(REPORT_TEMPLATE).render(&info_map)
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::{
        interface::admin_notification::{AdminNotification, ImageReportInfo},
        layer::data::mail::mail_info::MailInfo,
        layer::data::mail::mail_sender::MailSender,
        util::Uuid,
    };
    use dotenvy;
    use std::env::{self, VarError};
    use tracing_test::traced_test;

    const SMTP_SERVER_ENV_NAME: &str = "SMTP_SERVER";
    const SMTP_PORT_ENV_NAME: &str = "SMTP_PORT";
    const SMTP_USERNAME_ENV_NAME: &str = "SMTP_USERNAME";
    const SMTP_PASSWORD_ENV_NAME: &str = "SMTP_PASSWORD";
    const ADMIN_EMAIL_ENV_NAME: &str = "ADMIN_EMAIL";

    #[tokio::test]
    async fn test_get_report() {
        let info = get_report_info();
        let report = MailSender::get_report(&info).replace("\r\n", "\n");
        assert!(
            !report.contains("{{"),
            "the template must not contain any formatting"
        );
        assert!(
            !report.contains("}}"),
            "the template must not contain any formatting"
        );
        assert!(
            report.contains(info.image_link.as_str()),
            "the template must contain all of the information from the report info."
        );
        assert!(
            report.contains(info.image_id.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.report_count.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.image_got_hidden.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.positive_rating_count.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.negative_rating_count.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.get_image_rank.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.report_barrier.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
    }

    #[tokio::test]
    async fn test_try_notify_admin_image_report() {
        let mail_info = get_mail_info().unwrap();
        let mail_sender = MailSender::new(mail_info).unwrap();
        assert!(mail_sender.mailer.test_connection().unwrap());
        let report_info = get_report_info();

        assert!(mail_sender
            .try_notify_admin_image_report(&report_info)
            .is_ok());
    }

    #[tokio::test]
    #[traced_test]
    async fn test_notify_admin_iamge_report() {
        let mail_info = get_mail_info().unwrap();
        let mail_sender = MailSender::new(mail_info).unwrap();
        assert!(mail_sender.mailer.test_connection().unwrap());
        let report_info = get_report_info();
        mail_sender.notify_admin_image_report(report_info).await;

        logs_assert(|s| {
            assert!(s.iter().filter(|l| !l.contains("INFO")).count() == 0);
            assert!(s.iter().filter(|l| l.contains("INFO")).count() == 1);
            Ok(())
        });
    }

    fn get_report_info() -> ImageReportInfo {
        ImageReportInfo {
            reason: crate::util::ReportReason::Advert,
            image_got_hidden: true,
            image_id: Uuid::default(),
            image_link: String::from("www.test.com"),
            report_count: 1,
            positive_rating_count: 10,
            negative_rating_count: 20,
            get_image_rank: 1.0,
            report_barrier: 1,
        }
    }

    fn get_mail_info() -> Result<MailInfo, VarError> {
        dotenvy::dotenv().ok();
        Ok(MailInfo {
            smtp_server: env::var(SMTP_SERVER_ENV_NAME)?,
            smtp_port: env::var(SMTP_PORT_ENV_NAME)?.parse().unwrap(),
            username: env::var(SMTP_USERNAME_ENV_NAME)?,
            password: env::var(SMTP_PASSWORD_ENV_NAME)?,
            admin_email_address: env::var(ADMIN_EMAIL_ENV_NAME)?,
        })
    }
}
