use std::{collections::HashMap, fs};

use async_trait::async_trait;

use lettre::{transport::smtp::authentication::Credentials, Message, SmtpTransport, Transport};
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

const REPORT_TEMPLATE_FILE: &str = "template.txt";

pub struct MailSender {
    config: MailInfo,
    mailer: SmtpTransport,
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
    
    fn get_report(info: &ImageReportInfo) -> Result<String> {
        let template_file_contents =
            fs::read_to_string(REPORT_TEMPLATE_FILE).map_err(|_e| DataError::NoSuchItem)?;
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

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        match format!("app <{}>", self.config.username.clone()).parse() {
            Err(error) => warn!("The sender could not be created: {error}"),
            Ok(sender) => match format!("admin <{}>", self.config.admin_email_address).parse() {
                Err(error) => warn!("The reciever could not be created: {error:?}"),
                Ok(reciever) => match Self::get_report(&info) {
                    Err(error) => warn!("The template file could not be read: {error:?}"),
                    Ok(report) => {
                        match Message::builder()
                            .from(sender)
                            .to(reciever)
                            .subject("An image was reported for reviewing")
                            .body(report)
                        {
                            Err(error) => warn!("The email could not be created: {error:?}"),
                            Ok(email) => match self.mailer.send(&email) {
                                Ok(_) => info!("Email sent successfully!"),
                                Err(error) => warn!("Could not send email: {error:?}"),
                            },
                        }
                    }
                },
            },
        }
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use crate::{
        interface::admin_notification::{AdminNotification, ImageReportInfo},
        layer::data::mail::mail_sender::MailSender,
        startup::config::mail_info::MailInfo,
        util::Uuid,
    };

    #[tokio::test]
    async fn test_notify_admin_image_report() {
        let mail_info = MailInfo {
            smtp_server: String::from(" "),
            smtp_port: 465,
            username: String::from(" "),
            password: String::from(" "),
            admin_email_address: String::from(" "),
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
        mail_sender.notify_admin_image_report(report_info).await;
    }
}
