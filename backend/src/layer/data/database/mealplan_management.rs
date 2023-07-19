use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Line, Meal, Side},
        MealplanManagementDataAccess, Result,
    },
    util::{Additive, Allergen, Date, MealType, Price, Uuid},
};

pub struct PersistentMealplanManagementData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
impl MealplanManagementDataAccess for PersistentMealplanManagementData {
    async fn dissolve_relations(&self, canteen: Canteen, date: Date) {
        todo!()
    }
    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Canteen>> {
        todo!()
    }
    async fn get_similar_line(&self, similar_name: &str) -> Result<Option<Line>> {
        todo!()
    }
    async fn get_similar_meal(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Meal>> {
        todo!()
    }
    async fn get_similar_side(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Side>> {
        todo!()
    }

    async fn update_canteen(&self, uuid: Uuid, name: &str) -> Result<Canteen> {
        sqlx::query_as!(
            Canteen,
            "UPDATE canteen 
            SET canteen_id = $1, name = $2
            RETURNING canteen_id as id, name ",
            uuid, 
            name
        ).fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }
    async fn update_line(&self, uuid: Uuid, name: &str) -> Result<Line> {
        sqlx::query_as!(
            Line,
            "UPDATE line 
            SET line_id = $1, name = $2 
            RETURNING line_id as id, name, canteen_id",
            uuid, 
            name
        ).fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }
    async fn update_meal(
        &self,
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: &str,
        price: Price,
    ) -> Result<Meal> {
        todo!()
    }
    async fn update_side(
        &self,
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: &str,
        price: Price,
    ) -> Result<Side> {
        todo!()
    }

    async fn insert_canteen(&self, name: &str) -> Result<Canteen> {
        sqlx::query_as!(
            Canteen,
            "INSERT INTO canteen (name) 
            VALUES ($1) 
            RETURNING canteen_id as id, name ",
            name
        ).fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }
    async fn insert_line(&self, name: &str) -> Result<Line> {
        sqlx::query_as!(
            Line,
            "INSERT INTO line (name) 
            VALUES ($1) 
            RETURNING line_id as id, name, canteen_id",
            name
        ).fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }
    async fn insert_meal(
        &self,
        name: &str,
        meal_type: MealType,
        price: Price,
        next_served: Date,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Meal> {
        todo!()
    }
    async fn insert_side(
        &self,
        name: &str,
        meal_type: MealType,
        price: Price,
        next_served: Date,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Side> {
        todo!()
    }
}
