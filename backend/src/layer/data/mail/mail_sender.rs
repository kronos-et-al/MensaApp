use std::{collections::HashMap, fs};

use async_trait::async_trait;
use thiserror::Error;

use lettre::{
    address::AddressError, message::Mailbox, transport::smtp::authentication::Credentials, Message,
    SmtpTransport, Transport,
};
use uuid::fmt::Simple;

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        persistent_data::{DataError, Result},
    },
    startup::config::mail_info::MailInfo,
};

use string_template::Template;
use tracing::{info, warn};

pub type MailResult<T> = std::result::Result<T, MailError>;

const REPORT_TEMPLATE_FILE: &str = "--censored--/template.txt";

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
            warn!("{error:?}");
        }
    }
}

impl MailSender {
    /// Creates a new [`MailSender`] with the attributes defined in config. Also creates an SMTP connection to the smtp server defined in config
    ///
    /// # Errors
    /// Returns an error, if the connection could not be established to the smtp server
    pub fn new(config: MailInfo) -> Result<Self> {
        let creds = Credentials::new(config.username.clone(), config.password.clone());
        if let Ok(transport_builder) = SmtpTransport::relay(&config.smtp_server) {
            let mailer = transport_builder
                .port(config.smtp_port)
                .credentials(creds)
                .build();
            Ok(Self { config, mailer })
        } else {
            Err(DataError::NoSuchItem)
        }
    }

    fn try_notify_admin_image_report(&self, info: &ImageReportInfo) -> MailResult<()> {
        let sender = self.get_sender()?;
        let reciever = self.get_reciever()?;
        let report = Self::get_report(info)?;
        let email = Message::builder()
            .from(sender)
            .to(reciever)
            .subject("An image was reported for reviewing")
            .body(report)?;
        self.mailer.send(&email)?;
        info!("Email sent successfully!");
        Ok(())
    }

    fn get_sender(&self) -> MailResult<Mailbox> {
        format!("app <{}>", self.config.username.clone())
            .parse()
            .map_err(MailError::AddressError)
    }

    fn get_reciever(&self) -> MailResult<Mailbox> {
        format!("admin <{}>", self.config.admin_email_address)
            .parse()
            .map_err(MailError::AddressError)
    }

    fn get_report(info: &ImageReportInfo) -> MailResult<String> {
        let template_file_contents =
            fs::read_to_string(REPORT_TEMPLATE_FILE).map_err(MailError::TemplateError)?;
        let template = Template::new(&template_file_contents);
        let mut args = HashMap::new();
        let image_link: &str = &info.image_link;
        args.insert("image_link", image_link);
        let image_id: &str = &Simple::from_uuid(info.image_id).to_string();
        args.insert("image_id", image_id);
        let report_count: &str = &info.report_count.to_string();
        args.insert("report_count", report_count);
        let reason: &str = &info.reason.to_string();
        args.insert("reason", reason);
        let image_got_hidden: &str = &info.image_got_hidden.to_string();
        args.insert("image_got_hidden", image_got_hidden);
        let positive_rating_count: &str = &info.positive_rating_count.to_string();
        args.insert("positive_rating_count", positive_rating_count);
        let negative_rating_count: &str = &info.negative_rating_count.to_string();
        args.insert("negative_rating_count", negative_rating_count);
        let get_image_rank: &str = &info.get_image_rank.to_string();
        args.insert("get_image_rank", get_image_rank);

        Ok(template.render(&args))
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::{
        interface::admin_notification::ImageReportInfo, layer::data::mail::mail_sender::MailSender,
        startup::config::mail_info::MailInfo, util::Uuid,
    };

    #[tokio::test]
    async fn test_notify_admin_image_report() {
        let mail_info = MailInfo {
            smtp_server: String::from("--censored--"),
            smtp_port: 465,
            username: String::from("--censored--"),
            password: String::from("--censored--"),
            admin_email_address: String::from("--censored--"),
        };

        let mail_sender = MailSender::new(mail_info).unwrap();
        let report_info = ImageReportInfo {
            reason: crate::util::ReportReason::Advert,
            image_got_hidden: true,
            image_id: Uuid::default(),
            image_link: String::from("www.test.com"),
            report_count: 1,
            positive_rating_count: 10,
            negative_rating_count: 20,
            get_image_rank: 1.0,
        };
        if let Err(error) = mail_sender.try_notify_admin_image_report(&report_info) {
            println!("{error}");
            panic!();
        }
    }
}
