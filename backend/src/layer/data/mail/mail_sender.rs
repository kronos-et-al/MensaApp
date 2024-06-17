//! Module responsible for sending email notifications to administrators.
use std::fmt::Debug;

use async_trait::async_trait;
use minijinja::{context, Environment, Value};
use thiserror::Error;

use lettre::{
    address::AddressError,
    message::{Mailbox, MaybeString, SinglePart},
    transport::smtp::authentication::Credentials,
    Address, Message, SmtpTransport, Transport,
};

use crate::{
    interface::admin_notification::{AdminNotification, ImageReportInfo},
    layer::data::mail::mail_info::MailInfo,
};

use tracing::{error, info};

/// Result returned when sending emails, potentially containing a [`MailError`].
pub type MailResult<T> = std::result::Result<T, MailError>;

const REPORT_TEMPLATE: &str = include_str!("./template/template.html");
const REPORT_CSS: &str = include_str!("./template/output.css");
const SENDER_NAME: &str = "MensaKa";
const RECEIVER_NAME: &str = "Administrator";
const MAIL_SUBJECT: &str = "An image was reported and requires your review";

/// Enum describing the possible ways, the mail notification can fail.
#[derive(Debug, Error)]
pub enum MailError {
    /// Error occurring when an email address could not be parsed.
    #[error("an error occurred while parsing the addresses: {0}")]
    AddressError(#[from] AddressError),
    /// Error occurring when an email could not be constructed.
    #[error("an error occurred while parsing the mail: {0}")]
    MailParseError(#[from] lettre::error::Error),
    /// Error occurring when mail sender instance could bot be build.
    #[error("an error occurred while sending the mail: {0}")]
    MailSendError(#[from] lettre::transport::smtp::Error),
}

/// Class for sending emails.
pub struct MailSender {
    config: MailInfo,
    mailer: SmtpTransport,
}

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        if let Err(error) = self.try_notify_admin_image_report(&info) {
            error!(%info.image_id, %info.reason, self.config.admin_email_address, "Error notifying administrator: {error}");
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
            .singlepart(SinglePart::html(MaybeString::String(report)))?;
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
        let env = Environment::new();
        let template = env
            .template_from_str(REPORT_TEMPLATE)
            .expect("template always preset");

        template
            .render(context!(
                css => REPORT_CSS,
                delete_url => "#", // todo
                verify_url => "#", // todo
                ..Value::from_serialize(info),
            ))
            .expect("all arguments provided at compile time")
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use super::REPORT_CSS;
    use crate::{
        interface::admin_notification::{AdminNotification, ImageReportInfo},
        layer::data::mail::mail_info::MailInfo,
        layer::data::mail::mail_sender::MailSender,
        util::Uuid,
    };
    use chrono::Local;
    use dotenvy;
    use std::env::{self, VarError};
    use tracing_test::traced_test;

    const SMTP_SERVER_ENV_NAME: &str = "SMTP_SERVER";
    const SMTP_PORT_ENV_NAME: &str = "SMTP_PORT";
    const SMTP_USERNAME_ENV_NAME: &str = "SMTP_USERNAME";
    const SMTP_PASSWORD_ENV_NAME: &str = "SMTP_PASSWORD";
    const ADMIN_EMAIL_ENV_NAME: &str = "ADMIN_EMAIL";

    #[tokio::test]
    #[ignore]
    async fn test_print_report() {
        let info = get_report_info();
        let report = MailSender::get_report(&info);
        println!("{report}");
    }

    #[tokio::test]
    async fn test_get_report() {
        let info = get_report_info();
        let report = MailSender::get_report(&info).replace("\r\n", "\n");
        assert!(
            !report.contains("{{ "),
            "the template must not contain any formatting"
        );
        assert!(
            !report.contains(" }}"),
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
        // assert!(
        //     report.contains(info.image_got_hidden.to_string().as_str()),
        //     "the template must contain all of the information from the report info"
        // );
        assert!(
            report.contains(info.positive_rating_count.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.negative_rating_count.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.image_rank.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.report_barrier.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.client_id.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.image_age.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(REPORT_CSS), "Report css must be included. maybe auto-formatting destroyed the braces in template.html?"
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
            image_link: String::from("https://picsum.photos/200/300"),
            report_count: 1,
            positive_rating_count: 10,
            negative_rating_count: 20,
            image_rank: 1.0,
            report_barrier: 1,
            client_id: Uuid::default(),
            image_age: 1,
            meal_id: Uuid::default(),
            meal_name: "Happy Meal".into(),
            report_date: Local::now().date_naive(),
            other_image_urls: vec!["https://picsum.photos/200/300".into()],
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
