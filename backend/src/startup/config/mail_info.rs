

pub struct MailInfo {
    /// Name of the domain of the connection to the mail server over SMTP
    pub smtp_server: String,
    /// The port, which the mail server listens to SMTP-requests
    pub smtp_port: u32,
    /// Username for the connection to the mail server
    pub username: String,
    /// Password for the connection to the mail server
    pub password: String,
    /// E-mail address of an administrator, who gets notified for each image report
    pub admin_email_address: String,
}