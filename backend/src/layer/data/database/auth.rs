//! Module responsible for handling database requests for the authentication process.

use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::interface::persistent_data::{model::ApiKey, AuthDataAccess, Result};

/// Class implementing all database requests arising from graphql manipulations.
#[derive(Debug)]
pub struct PersistentAuthData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
impl AuthDataAccess for PersistentAuthData {
    async fn get_api_keys(&self) -> Result<Vec<ApiKey>> {
        let keys = sqlx::query_as!(
            ApiKey,
            "SELECT api_key as key, description FROM api_key ORDER BY api_key"
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(keys)
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use sqlx::PgPool;

    use super::PersistentAuthData;
    use crate::interface::persistent_data::{model::ApiKey, AuthDataAccess};

    #[sqlx::test(fixtures("api_key"))]
    async fn test_get_api_keys(pool: PgPool) {
        let auth = PersistentAuthData { pool: pool.clone() };

        assert!(auth.get_api_keys().await.is_ok());
        assert_eq!(auth.get_api_keys().await.unwrap(), provide_dummy_api_keys());
    }

    fn provide_dummy_api_keys() -> Vec<ApiKey> {
        vec![
            ApiKey {
                key: "abc".into(),
                description: String::new(),
            },
            ApiKey {
                key: "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into(),
                description: String::new(),
            },
        ]
    }
}
