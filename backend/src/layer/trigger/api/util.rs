//! Module containing some helper functions like for working inside the graphql context and processing authentication headers.
use async_graphql::{Context, UploadValue};
use base64::{engine::general_purpose, Engine};
use futures::AsyncReadExt;
use sha2::{Digest, Sha512};
use thiserror::Error;

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
    /// # Errors
    /// if no valid authentication present
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
        if self.data_unchecked::<AuthInfo>().authenticated.is_ok() {
            Ok(())
        } else {
            let auth_info = self.get_auth_info();
            Err(auth::AuthError::MissingOrInvalidAuth(auth_info.clone()))
        }
    }

    fn get_client_id(&self) -> auth::Result<Uuid> {
        self.data_unchecked::<AuthInfo>()
            .client_id
            .ok_or(auth::AuthError::MissingClientId)
    }
}

/// Reads data from an upload and validates it against a hash.
/// # Errors
/// - Upload could not be read
/// - hash ist not valid base 64
/// - hash does not match with upload
pub async fn read_and_validate_upload(upload: UploadValue, hash: String) -> UploadResult<Vec<u8>> {
    let mut upload_data = Vec::new();
    let _ = upload
        .into_async_read()
        .read_to_end(&mut upload_data)
        .await
        .map_err(UploadError::IoError)?;

    let calculated_hash = Sha512::new().chain_update(&upload_data).finalize().to_vec();

    let given_hash = general_purpose::STANDARD
        .decode(&hash)
        .map_err(|_| UploadError::HashNotBase64)?;

    if calculated_hash != given_hash {
        let calculated_base64 = general_purpose::STANDARD.encode(calculated_hash);
        Err(UploadError::InvalidHash(calculated_base64, hash))?;
    }

    Ok(upload_data)
}

/// Result returned from upload preprocessing and validation operations.
pub type UploadResult<T> = Result<T, UploadError>;

/// Error marking something went wrong with preprocessing and validating an upload.
#[derive(Error, Debug)]
pub enum UploadError {
    /// Error indicating an upload could not be read.
    #[error("Could not read uploaded file: {0}")]
    IoError(std::io::Error),
    /// Error indicating a hash was not in a valid base 64 encoding.
    #[error("The provided hash is not a valid base 64 encoding.")]
    HashNotBase64,
    /// Error indicating that a wring file hash was given.
    /// First parameter is the _expected_ hash, second the _given_.
    #[error("The given hash does not match with the uploaded file.\nExpected: {0}\nGot: {1}")]
    InvalidHash(String, String),
}
