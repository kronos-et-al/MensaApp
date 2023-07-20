use async_trait::async_trait;

use lettre::{transport::smtp::authentication::Credentials, Message, SmtpTransport, Transport};

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
        let email = Message::builder()
            .from(
                format!("app <{}>", self.config.username.clone())
                    .parse()
                    .expect("HELP!"),
            )
            .to(format!("admin <{}>", self.config.admin_email_address)
                .parse()
                .expect("HELP!"))
            .subject("Hello")
            .body(format!("{info:#?}"))
            .expect("HELP!");

        let creds = Credentials::new(self.config.username.clone(), self.config.password.clone());

        // Open a remote connection to gmail
        let mailer = SmtpTransport::relay(&self.config.smtp_server)
            .expect("HELP!")
            .port(self.config.smtp_port)
            .credentials(creds)
            .build();

        // Send the email
        match mailer.send(&email) {
            Ok(_) => println!("Email sent successfully!"),
            Err(e) => panic!("Could not send email: {e:?}"),
        }
    }
}

#[cfg(test)]
mod test {
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

        let mail_sender = MailSender::new(mail_info);
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
