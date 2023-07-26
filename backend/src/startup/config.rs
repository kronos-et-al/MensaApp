use crate::layer::{data::{database::factory::DatabaseInfo, mail::mail_info::MailInfo, flickr_api::flickr_api_handler::{FlickrInfo}, swka_parser::swka_parse_manager::SwKaInfo}, trigger::{scheduling::scheduler::ScheduleInfo, graphql::server::GraphQLServerInfo}};

use super::server::Result;

/// Class for reading configuration from environment variables.
pub struct ConfigReader;

impl ConfigReader {
    /// Reads the config for accessing the database from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_database_info() -> Result<DatabaseInfo> {
        todo!()
    }
    
    /// Reads the config for accessing the mail server from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_mail_info() -> Result<MailInfo> {
        todo!()
    }

    /// Reads the schedules for regular events from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_schedule_info() -> Result<ScheduleInfo> {
        todo!()
    }

    /// Reads the config for the flickr api from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_flickr_info() -> Result<FlickrInfo> {
        todo!()
    }

    /// Reads the config for the homepage of the "Studierendenwerk Karlsruhe" (SwKa) and its canteens from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_swka_info() -> Result<SwKaInfo> {
        todo!()
    }

    /// Reads the config for the graphql web server from environment variables. 
    /// If the necessary configurations are not available, an error will be returned.  
    pub fn read_graphql_info() -> Result<GraphQLServerInfo> {
        todo!()
    }


}
