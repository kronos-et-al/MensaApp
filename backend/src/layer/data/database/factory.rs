use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

use super::command::PersistentCommandData;

/// Structure containing all information necessary to connect to a database.
pub struct DatabaseInfo {
    ///
    pub connection: String,
}

/// This class is responsible for instantiating the database access implementations classes.
pub struct DataAccessFactory {
    pool: Pool<Postgres>,
}

const MAX_DB_CONNECTIONS: u32 = 20;

impl DataAccessFactory {
    /// Creates a new factory object for the database access instances.
    /// On creation, a connection to the database is established.
    pub async fn new(info: DatabaseInfo) -> Self {
        let pool = PgPoolOptions::new()
            .max_connections(MAX_DB_CONNECTIONS)
            .connect(&info.connection)
            .await
            .expect("cannot connect to database");
        Self { pool }
    }

    #[must_use]
    pub fn get_command_data_access(&self) -> PersistentCommandData {
        PersistentCommandData {
            pool: self.pool.clone(),
        }
    }
}
