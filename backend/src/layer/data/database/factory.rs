use sqlx::{postgres::PgPoolOptions, Pool, Postgres};

use super::{
    command::PersistentCommandData, image_review::PersistentImageReviewData,
    mealplan_management::PersistentMealplanManagementData, request::PersistentRequestData,
};

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