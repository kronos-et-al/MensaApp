//! Module responsible for authenticating api commands by verifying hashes over the api key and data.
use base64::{engine::general_purpose::STANDARD, Engine};

use sha2::{Digest, Sha512};

use crate::interface::api_command::{CommandError, InnerAuthInfo, Result};

use super::command_type::CommandType;

/// Class for authenticating commands.
#[derive(Debug)]
pub struct Authenticator {
    api_keys: Vec<String>,
}

impl Authenticator {
    /// Creates a new object which authenticates requests against the given list of valid api keys.
    #[must_use]
    pub fn new(api_keys: Vec<String>) -> Self {
        Self { api_keys }
    }

    /// Authenticates a commands by checking if the given hash conforms with the given api key.
    /// # Errors
    /// - [`CommandError::BadAuth`] is returned when authentication failed.
    pub fn authn_command(
        &self,
        auth_info: &InnerAuthInfo,
        command_type: &CommandType,
    ) -> Result<()> {
        let hash = self.calculate_hash(
            auth_info,
            &command_type.to_string(),
            command_type.get_bytes(),
        )?;
        let provided_hash = Self::get_provided_hash(auth_info)?;

        if hash == provided_hash {
            Ok(())
        } else {
            Err(CommandError::BadAuth(format!(
                "hash not matching: {auth_info}"
            )))
        }
    }

    fn calculate_hash(
        &self,
        auth_info: &InnerAuthInfo,
        request_name: &str,
        params: Vec<u8>,
    ) -> Result<Vec<u8>> {
        let api_key = self.get_api_key(auth_info)?;
        let hasher = Sha512::new()
            .chain_update(request_name)
            .chain_update(auth_info.client_id)
            .chain_update(api_key)
            .chain_update(params);

        Ok(Vec::from(&hasher.finalize()[..]))
    }

    fn get_provided_hash(auth_info: &InnerAuthInfo) -> Result<Vec<u8>> {
        STANDARD
            .decode(&auth_info.hash)
            .map_err(|_| CommandError::BadAuth(format!("could not decode hash: {auth_info}")))
    }

    fn get_api_key(&self, auth_info: &InnerAuthInfo) -> Result<String> {
        self.api_keys
            .iter()
            .find(|key| key.starts_with(&auth_info.api_ident))
            .map(Clone::clone)
            .ok_or(CommandError::BadAuth(format!(
                "no matching api key found for `{}`",
                auth_info.api_ident
            )))
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use crate::{
        interface::api_command::InnerAuthInfo,
        layer::logic::api_command::auth::command_type::CommandType,
        util::{ReportReason, Uuid},
    };

    use super::Authenticator;

    #[test]
    fn test_auth_image_add_down() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "Xz+c2URLRn6rDa58ExTWPXsj3FXnXu/3nPmV62XqypXkQnJTCwI/m9idDRyBqVjqh9ysPKd9tm6JngY/BSYh3Q==".into(),
            client_id: Uuid::default(),
        };

        let image_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        let command = CommandType::AddDownvote { image_id };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());

        let info2 = InnerAuthInfo {
            hash: "AQPykbV6530qtbsE93KZsgl0KvORCz5LYH+HhzUSiX1FAFUjo/52y7rnTRq9tlUN3dzRa8xHxWg5y2PwIkItdg==".into(), // wrong hash
            ..info.clone()
        };

        let ok = auth.authn_command(&info2, &command);
        assert!(ok.is_err());

        let info3 = InnerAuthInfo {
            api_ident: "Abcsa".into(), // wrong api ident
            ..info.clone()
        };

        let ok = auth.authn_command(&info3, &command);
        assert!(ok.is_err());

        let info4 = InnerAuthInfo {
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(), // wrong client id
            ..info.clone()
        };

        let ok = auth.authn_command(&info4, &command);
        assert!(ok.is_err());

        let command2 = CommandType::AddUpvote { image_id }; // wrong command type

        let ok = auth.authn_command(&info, &command2);
        assert!(ok.is_err());

        let command3 = CommandType::AddDownvote {
            image_id: Uuid::default(), // wrong image id
        };

        let ok = auth.authn_command(&info, &command3);
        assert!(ok.is_err());
    }

    #[test]
    fn test_auth_image_add_up() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "AQPykbV6530qtbsE93KZsgl0KvORCz5LYH+HhzUSiX1FAFUjo/52y7rnTRq9tlUN3dzRa8xHxWg5y2PwIkItdg==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };

        let command = CommandType::AddUpvote {
            image_id: Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap(),
        };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());
    }

    #[test]
    fn test_auth_image_remove_up() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "8jYXv/+3YqO9j9zJnrkSGy4Bx1VZLgXoW95RodDWZ/PmzcAqqhyKiv2gI09JCBUuBOZoDMkNPhCjbesBkCGaxg==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };

        let command = CommandType::RemoveUpvote {
            image_id: Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap(),
        };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());
    }

    #[test]
    fn test_auth_image_remove_down() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "lb4TH+zjHTl0Z9zijEZ7KtOFIBFHvY70rmZtX+Xk/fa++fGJtAS10EjFOqAgx/0scDJDbhpdn9WS5Yy5zCYeoQ==".into(),
            client_id: Uuid::try_from("4c57fc70-4839-4398-be08-d151c0dbb246").unwrap(),
        };

        let command = CommandType::RemoveDownvote {
            image_id: Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap(),
        };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());
    }

    #[test]
    fn test_auth_add_image() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "ozNFvc9F0FWdrkFuncTpWA8z+ugwwox4El21hNiHoJW1conWnAOL0q7g4iNWEdDViFyTBjmDhK17FKpmReAgrA==".into(),
            client_id: Uuid::default(),
        };

        let meal_id = Uuid::try_from("1d170ff5-e18b-4c45-b452-8feed7328cd3").unwrap();
        let command = CommandType::AddImage {
            meal_id,
            url: "http://test.de".into(),
        };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());

        let command2 = CommandType::AddImage {
            url: "hello".into(), // wrong url
            meal_id,
        };

        let ok = auth.authn_command(&info, &command2);
        assert!(ok.is_err());
    }

    #[test]
    fn test_auth_rate_meal() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "rHh8opE3qYEupyehP6ttMLVpgV0lTmGJE4rV53oFUUGCdQkzZnUu2snS/Hr4ZyYZ/1D7WiLonHSldbYSMLVBVQ==".into(),
            client_id: Uuid::default(),
        };

        let meal_id = Uuid::try_from("94cf40a7-ade4-4c1f-b718-89b2d418c2d0").unwrap();
        let command = CommandType::SetRating { meal_id, rating: 2 };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());

        let command2 = CommandType::SetRating {
            meal_id,
            rating: 90,
        };

        let ok = auth.authn_command(&info, &command2);
        assert!(ok.is_err());
    }

    #[test]
    fn test_auth_report_image() {
        let auth = Authenticator::new(vec![
            "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into()
        ]);

        let info = InnerAuthInfo {
            api_ident: "YWpzZGg4Mn".into(),
            hash: "zsqn7BQuQZDKhEs2kgjKRA5sAFStu6P+WnF8bEtmU6VVZ7SZn6FB8cUFadoT6s7j9y1MqYMMb3DPctimykn+mg==".into(),
            client_id: Uuid::try_from("b637365e-9ec5-47cf-8e39-eab3e10de4e5").unwrap(),
        };

        let image_id = Uuid::try_from("afa781ab-278f-441a-9241-f70e1013ed42").unwrap();
        let command = CommandType::ReportImage {
            image_id,
            reason: ReportReason::Advert,
        };

        let ok = auth.authn_command(&info, &command);
        assert!(ok.is_ok());

        let command2 = CommandType::ReportImage {
            image_id,
            reason: ReportReason::WrongMeal,
        };
        let ok = auth.authn_command(&info, &command2);
        assert!(ok.is_err());
    }
}
