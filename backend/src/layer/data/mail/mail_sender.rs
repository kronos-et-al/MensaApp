use async_trait::async_trait;

use lettre::{transport::smtp::authentication::Credentials, Message, SmtpTransport, Transport};

use crate::{
    interface::{
        admin_notification::{AdminNotification, ImageReportInfo},
        persistent_data::{DataError, Result},
    },
    startup::config::mail_info::MailInfo,
};

use tracing::{info, warn};

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
    fn get_report(info: &ImageReportInfo) -> String {
        let image_link = info.image_link.as_str();
        let image_id = info.image_id;
        let report_count = info.report_count;
        let reason = info.reason;
        let image_got_hidden = info.image_got_hidden;
        let positive_rating_count = info.positive_rating_count;
        let negative_rating_count = info.negative_rating_count;
        let get_image_rank = info.get_image_rank;

        format!(
            "The image at the url {image_link}
        with the id {image_id}
        was reported {report_count} times.
        Reason: {reason}
        Image automatically hidden: {image_got_hidden}
        
        Additional Data:
        Positive ratings: {positive_rating_count}
        Negative ratings: {negative_rating_count}
        Rank: {get_image_rank}
        "
        )
    }
}

#[async_trait]
impl AdminNotification for MailSender {
    async fn notify_admin_image_report(&self, info: ImageReportInfo) {
        match format!("app <{}>", self.config.username.clone()).parse() {
            Err(error) => warn!("The sender could not be created: {error}"),
            Ok(sender) => match format!("admin <{}>", self.config.admin_email_address).parse() {
                Err(error) => warn!("The reciever could not be created: {error}"),
                Ok(reciever) => {
                    match Message::builder()
                        .from(sender)
                        .to(reciever)
                        .subject("An image was reported for reviewing")
                        .body(Self::get_report(&info))
                    {
                        Err(error) => warn!("The email could not be created: {error}"),
                        Ok(email) => match self.mailer.send(&email) {
                            Ok(_) => info!("Email sent successfully!"),
                            Err(e) => warn!("Could not send email: {e:?}"),
                        },
                    }
                }
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
