use async_graphql::Data;
use async_trait::async_trait;
use sqlx::{Database, Pool, Postgres};

use super::types::DatabasePrice;
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
    async fn dissolve_relations(&self, canteen_id: Uuid, date: Date) -> Result<()> {
        sqlx::query!(
            "
            DELETE FROM food_plan
            WHERE serve_date = $1
            AND line_id IN (SELECT line_id FROM line WHERE canteen_id = $2)
            ",
            date,
            canteen_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Uuid>> {
        todo!()
    }

    async fn get_similar_line(&self, similar_name: &str) -> Result<Option<Uuid>> {
        todo!()
    }

    async fn get_similar_meal(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        todo!()
    }

    async fn get_similar_side(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        todo!()
    }

    async fn update_canteen(&self, uuid: Uuid, name: &str) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            UPDATE canteen
            SET name = $2
            WHERE canteen_id = $1
            RETURNING canteen_id
            ",
            uuid,
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_line(&self, uuid: Uuid, name: &str) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            UPDATE line
            SET name = $2
            WHERE line_id = $1
            RETURNING line_id
            ",
            uuid,
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_meal(&self, uuid: Uuid, name: &str) -> Result<()> {
        self.update_food(uuid, name).await
    }

    async fn update_side(&self, uuid: Uuid, name: &str) -> Result<()> {
        self.update_food(uuid, name).await
    }

    async fn add_meal_to_plan(
        &self,
        meal_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        self.add_to_plan(meal_id, line_id, date, price).await
    }

    async fn add_side_to_plan(
        &self,
        side_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        self.add_to_plan(side_id, line_id, date, price).await
    }

    async fn insert_canteen(&self, name: &str) -> Result<Uuid> {
        sqlx::query_scalar!(
            // TODO canteen psoition
            "
            INSERT INTO canteen (name)
            VALUES ($1)
            RETURNING canteen_id
            ",
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn insert_line(&self, name: &str) -> Result<Uuid> {
        sqlx::query_scalar!(
            // TODO line position
            "
            INSERT INTO line (name)
            VALUES ($1)
            RETURNING line_id
            ",
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn insert_meal(
        &self,
        name: &str,
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        self.insert_food(name, meal_type, allergens, additives)
            .await
    }

    async fn insert_side(
        &self,
        name: &str,
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        self.insert_food(name, meal_type, allergens, additives)
            .await
    }
}

impl PersistentMealplanManagementData {
    async fn update_food(&self, food_id: Uuid, food_name: &str) -> Result<()> {
        sqlx::query!(
            "UPDATE food SET name = $2 WHERE food_id = $1",
            food_id,
            food_name
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn add_to_plan(
        &self,
        food_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        let price: DatabasePrice = price.try_into()?;
        sqlx::query!(
            "INSERT INTO food_plan (line_id, food_id, serve_date, prices) VALUES ($1, $2, $3, $4)",
            line_id,
            food_id,
            date,
            price as _
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn insert_food(
        &self,
        name: &str,
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        let food_id = sqlx::query_scalar!(
            "INSERT INTO food(name, food_type) VALUES ($1, $2) RETURNING food_id",
            name,
            meal_type as _
        )
        .fetch_one(&self.pool)
        .await?;

        sqlx::query!("INSERT INTO meal(food_id) VALUES ($1)", food_id)
            .execute(&self.pool)
            .await?;

        let allergens: Vec<String> = allergens
            .iter()
            .copied()
            .map(Allergen::to_db_string)
            .collect();

        sqlx::query!(
            "INSERT INTO food_allergen(food_id, allergen) VALUES ($1, UNNEST($2::allergen[]))",
            food_id,
            allergens as _
        )
        .execute(&self.pool)
        .await?;

        let additives: Vec<String> = additives
            .iter()
            .copied()
            .map(Additive::to_db_string)
            .collect();

        sqlx::query!(
            "INSERT INTO food_additive(food_id, additive) VALUES ($1, UNNEST($2::additive[]))",
            food_id,
            additives as _
        )
        .execute(&self.pool)
        .await?;

        Ok(food_id)
    }
}
