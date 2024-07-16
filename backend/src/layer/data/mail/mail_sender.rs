//! Module responsible for sending email notifications to administrators.

use async_trait::async_trait;
use minijinja::{context, Environment, Value};

use crate::{
    interface::admin_notification::{AdminNotification, ImageReportInfo, Result},
    layer::data::mail::mail_info::MailInfo,
    util::{self, Uuid},
};
use lettre::{
    message::{Mailbox, MaybeString, SinglePart},
    transport::smtp::authentication::Credentials,
    Address, Message, SmtpTransport, Transport,
};

use tracing::{error, info};

const REPORT_TEMPLATE: &str = include_str!("./template/template.html");
const NOTIFY_TEMPLATE: &str = include_str!("./template/notification.html");
const REPORT_CSS: &str = include_str!("./template/output.css");
const SENDER_NAME: &str = "MensaKa";
const RECEIVER_NAME: &str = "Administrator";

/// Class for sending emails.
pub struct MailSender {
    config: MailInfo,
    mailer: SmtpTransport, // todo async transport?
}

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        if let Err(error) = self.try_notify_admin_image_report(&info) {
            error!(%info.image_id, %info.reason, self.config.admin_email_address, "Error notifying administrator: {error}");
        }
    }
    async fn notify_admin_image_deleted(&self, image_id: Uuid) -> Result<()> {
        let subject = format!("❌ Image {}… deleted", &image_id.to_string()[..6],);

        let body = Self::get_notification_body("deleted", image_id);

        self.send_message(subject, image_id, body)
    }

    async fn notify_admin_image_verified(&self, image_id: Uuid) -> Result<()> {
        let subject = format!("✅ Image {}… verified", &image_id.to_string()[..6],);

        let body = Self::get_notification_body("verified", image_id);

        self.send_message(subject, image_id, body)
    }
}

impl MailSender {
    /// Creates a new [`MailSender`] with the attributes defined in config. Also creates an SMTP connection to the smtp server defined in config
    ///
    /// # Errors
    /// Returns an error, if the connection could not be established to the smtp server
    pub fn new(config: MailInfo) -> Result<Self> {
        let creds = Credentials::new(config.username.clone(), config.password.clone());
        let transport_builder = SmtpTransport::relay(&config.smtp_server)?;
        let mailer = transport_builder
            .port(config.smtp_port)
            .credentials(creds)
            .build();
        Ok(Self { config, mailer })
    }

    fn try_notify_admin_image_report(&self, info: &ImageReportInfo) -> Result<()> {
        let report = Self::get_report(info);

        let subject = format!(
            "{icon} Image {}… {}, {}x: {}",
            &info.image_id.to_string()[..6],
            if info.image_got_hidden {
                "hidden"
            } else {
                "reported"
            },
            info.report_count,
            info.reason,
            icon = if info.image_got_hidden {
                "👻"
            } else {
                "📜"
            }
        );

        self.send_message(subject, info.image_id, report)?;
        info!(
            ?info,
            "Notified administrators about image report for image with id {}", info.image_id,
        );
        Ok(())
    }

    fn get_sender(&self) -> Result<Mailbox> {
        let address = self.config.username.parse::<Address>()?;
        Ok(Mailbox::new(Some(SENDER_NAME.to_string()), address))
    }

    fn get_receiver(&self) -> Result<Mailbox> {
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
                delete_url => util::local_to_global_url(&format!("/admin/report/delete_image/{}", info.image_id)),
                verify_url => util::local_to_global_url(&format!("/admin/report/verify_image/{}", info.image_id)),
                ..Value::from_serialize(info),
            ))
            .expect("all arguments provided at compile time")
    }

    fn get_notification_body(action: &str, image_id: Uuid) -> String {
        let env = Environment::new();
        let template = env
            .template_from_str(NOTIFY_TEMPLATE)
            .expect("template always preset");

        template
            .render(context!(
                css => REPORT_CSS,
                action => action,
                image_id => image_id,
            ))
            .expect("all arguments provided at compile time")
    }

    fn get_references_tag(image_id: Uuid) -> String {
        format!("<{image_id}@image-reports.mensa-ka.de>")
    }

    fn send_message(&self, subject: impl Into<String>, image_id: Uuid, body: String) -> Result<()> {
        let message = Message::builder()
            .from(self.get_sender()?)
            .to(self.get_receiver()?)
            .subject(subject)
            .references(Self::get_references_tag(image_id))
            .singlepart(SinglePart::html(MaybeString::String(body)))?;
        self.mailer.send(&message)?;
        Ok(())
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
            report.contains(info.image_url.as_str()),
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
            report.contains(&info.image_rank.to_string()[0..4]),
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
            report.contains(info.meal_id.to_string().as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.meal_name.as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.other_image_urls[0].as_str()),
            "the template must contain all of the information from the report info"
        );
        assert!(
            report.contains(info.report_date.to_string().as_str()),
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

    #[tokio::test]
    async fn test_notify_admin_image_deleted() {
        let mail_info = get_mail_info().unwrap();
        let sender = MailSender::new(mail_info).unwrap();
        assert!(sender.mailer.test_connection().unwrap());

        let id = Uuid::default();

        assert!(sender.notify_admin_image_deleted(id).await.is_ok());
    }

    #[tokio::test]
    async fn test_notify_admin_image_verified() {
        let mail_info = get_mail_info().unwrap();
        let sender = MailSender::new(mail_info).unwrap();
        assert!(sender.mailer.test_connection().unwrap());

        let id = Uuid::default();

        assert!(sender.notify_admin_image_verified(id).await.is_ok());
    }

    fn get_report_info() -> ImageReportInfo {
        ImageReportInfo {
            reason: crate::util::ReportReason::Advert,
            image_got_hidden: true,
            image_id: Uuid::from_u128(9_789_789),
            image_url: String::from("https://picsum.photos/500/200"),
            report_count: 1,
            positive_rating_count: 10,
            negative_rating_count: 20,
            image_rank: 0.123_456,
            report_barrier: 1,
            client_id: Uuid::from_u128(123),
            image_age: 1,
            meal_id: Uuid::from_u128(567),
            meal_name: "Happy Meal".into(),
            report_date: Local::now().date_naive(),
            other_image_urls: vec![
                "https://picsum.photos/500/300".into(),
                "https://picsum.photos/500/350".into(),
                "https://picsum.photos/400/350".into(),
                "https://picsum.photos/300/350".into(),
            ],
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
