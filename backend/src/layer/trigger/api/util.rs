//! Module containing some helper functions like for working inside the graphql context and processing authentication headers.
use async_graphql::Context;
use tracing::debug;

use crate::{
    interface::{api_command::Command, persistent_data::RequestDataAccess},
    util::Uuid,
};

use super::auth::{self, AuthInfo};

/// Type for storing the data access class inside the graphql context.
pub type DataBox = Box<dyn RequestDataAccess + Sync + Send + 'static>;
/// Type for storing the command implementations inside the graphql context.
pub type CommandBox = Box<dyn Command + Sync + Send + 'static>;

/// Utility trait with convenience methods for accessing data stored inside the graphql context.
pub trait ApiUtil {
    /// Returns access to the command implementation.
    fn get_command(&self) -> &(dyn Command + Sync + Send);
    /// Returns access to the datastore.
    fn get_data_access(&self) -> &(dyn RequestDataAccess + Sync + Send);

    /// Returns all information about the authentication status of this request.
    fn get_auth_info(&self) -> &AuthInfo;

    /// Returns whether this request is authenticated correctly.
    fn check_authentication(&self) -> auth::Result<()>;

    /// Gets the provided client id, if any.
    /// # Errors
    /// if no client id was provided in the authorization header
    fn get_client_id(&self) -> auth::Result<Uuid>;
}

impl<'a> ApiUtil for Context<'a> {
    fn get_command(&self) -> &'a (dyn Command + Sync + Send) {
        self.data_unchecked::<CommandBox>().as_ref()
    }

    fn get_data_access(&self) -> &'a (dyn RequestDataAccess + Sync + Send) {
        self.data_unchecked::<DataBox>().as_ref()
    }

    fn get_auth_info(&self) -> &AuthInfo {
        self.data_unchecked::<AuthInfo>()
    }

    fn check_authentication(&self) -> auth::Result<()> {
        if self.data_unchecked::<AuthInfo>().authenticated {
            Ok(())
        } else {
            debug!(
                auth = ?self.get_auth_info(),
                "Unauthenticated Graphql request!",
            );
            Err(auth::AuthError::MissingOrInvalidAuth)
        }
    }

    fn get_client_id(&self) -> auth::Result<Uuid> {
        self.data_unchecked::<AuthInfo>()
            .client_id
            .ok_or(auth::AuthError::MissingClientId)
    }
}
