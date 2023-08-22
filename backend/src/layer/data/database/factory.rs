use sqlx::{postgres::PgPoolOptions, Pool, Postgres};
use tracing::info;

use crate::interface::persistent_data::Result;

use super::{
    command::PersistentCommandData, image_review::PersistentImageReviewData,
    mealplan_management::PersistentMealplanManagementData, request::PersistentRequestData,
};

/// Structure containing all information necessary to connect to a database.
pub struct DatabaseInfo {
    /// Connection string to database of format `postgres://<username>:<password>@<host>:<port>/<database>`.
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
    /// If wished, database migrations can be applied to create the wanted relations.
    /// # Errors
    /// if a migrations should, but could not run
    pub async fn new(info: DatabaseInfo, should_migrate: bool) -> Result<Self> {
        let pool = PgPoolOptions::new()
            .max_connections(MAX_DB_CONNECTIONS)
            .connect(&info.connection)
            .await
            .expect("cannot connect to database");

        if should_migrate {
            sqlx::migrate!().run(&pool).await?;
            info!("Successfully run database migrations");
        }

        Ok(Self { pool })
    }

    /// Returns a object for accessing database requests for api commands.
    #[must_use]
    pub fn get_command_data_access(&self) -> PersistentCommandData {
        PersistentCommandData {
            pool: self.pool.clone(),
        }
    }

    /// Returns a object for accessing database requests for the image reviewing process.
    #[must_use]
    pub fn get_image_review_data_access(&self) -> PersistentImageReviewData {
        PersistentImageReviewData {
            pool: self.pool.clone(),
        }
    }

    /// Returns a object for accessing database requests for the meal plan management.
    #[must_use]
    pub fn get_mealplan_management_data_access(&self) -> PersistentMealplanManagementData {
        PersistentMealplanManagementData {
            pool: self.pool.clone(),
        }
    }

    /// Returns a object for accessing database requests for api requests.
    #[must_use]
    pub fn get_request_data_access(&self) -> PersistentRequestData {
        PersistentRequestData {
            pool: self.pool.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use dotenvy::dotenv;
    use sqlx::migrate::MigrateDatabase;

    use crate::layer::data::database::factory::{DataAccessFactory, DatabaseInfo};

    #[tokio::test]
    async fn test_factory() {
        dotenv().ok();
        let mut connection = std::env::var("DATABASE_URL").expect("test needs DATABASE_URL set");
        connection.push_str("_test");

        sqlx::Postgres::create_database(&connection)
            .await
            .expect("failed to create test database");

        let info = DatabaseInfo {
            connection: connection.clone(),
        };
        let factory = DataAccessFactory::new(info, true)
            .await
            .expect("failed to access test database");
        _ = factory.get_command_data_access();
        _ = factory.get_image_review_data_access();
        _ = factory.get_mealplan_management_data_access();
        _ = factory.get_request_data_access();

        std::mem::drop(factory); // drop database connection

        sqlx::Postgres::drop_database(&connection)
            .await
            .expect("failed to delete test database");
    }
}
