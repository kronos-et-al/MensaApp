use async_trait::async_trait;
use sqlx::{Pool, Postgres};

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
    async fn dissolve_relations(&self, canteen: Canteen, date: Date) -> Result<()> {
        sqlx::query!(
            "
            DELETE FROM food_plan
            WHERE serve_date = $1 
            AND line_id IN (SELECT line_id FROM line WHERE canteen_id = $2)
            ",
            date,
            canteen.id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
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
            "
            UPDATE canteen 
            SET name = $2
            WHERE canteen_id = $1
            RETURNING canteen_id as id, name
            ",
            uuid,
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_line(&self, uuid: Uuid, name: &str) -> Result<Line> {
        sqlx::query_as!(
            Line,
            "
            UPDATE line 
            SET name = $2
            WHERE line_id = $1
            RETURNING line_id as id, name, canteen_id
            ",
            uuid,
            name
        )
        .fetch_one(&self.pool)
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
        sqlx::query!("UPDATE food SET name = $2 WHERE food_id = $1", uuid, name)
            .execute(&self.pool)
            .await?;
        let price: DatabasePrice = price.try_into()?;
        sqlx::query!(
            "INSERT INTO food_plan(food_id, line_id, serve_date, prices) VALUES ($1, $2, $3, $4)",
            uuid,
            line_id,
            date,
            price as _
        )
        .execute(&self.pool)
        .await?;

        // Todo is the complete meal really needed? not returning it would make things much more simpler
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
        // todo same as meal? combine?
        sqlx::query!("UPDATE food SET name = $2 WHERE food_id = $1", uuid, name)
            .execute(&self.pool)
            .await?;
        let price: DatabasePrice = price.try_into()?;
        sqlx::query!(
            "INSERT INTO food_plan(food_id, line_id, serve_date, prices) VALUES ($1, $2, $3, $4)",
            uuid,
            line_id,
            date,
            price as _
        )
        .execute(&self.pool)
        .await?;

        // Todo is the complete meal really needed? not returning it would make things much more simpler
        todo!()
    }

    async fn insert_canteen(&self, name: &str) -> Result<Canteen> {
        sqlx::query_as!(
            Canteen,
            "
            INSERT INTO canteen (name) 
            VALUES ($1) 
            RETURNING canteen_id as id, name
            ",
            name
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn insert_line(&self, name: &str) -> Result<Line> {
        sqlx::query_as!(
            Line,
            "
            INSERT INTO line (name) 
            VALUES ($1) 
            RETURNING line_id as id, name, canteen_id
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
        price: Price,
        next_served: Date,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Meal> {
        let record = sqlx::query!(
            "INSERT INTO food(name, food_type) VALUES ($1, $2) RETURNING food_id",
            name,
            meal_type as _
        )
        .fetch_one(&self.pool)
        .await?;

        sqlx::query!("INSERT INTO meal(food_id) VALUES ($1)", record.food_id)
            .execute(&self.pool)
            .await?;

        let additives: Vec<String> = additives.iter().map(|a| "a".into()).collect(); // todo map to string manually?

        sqlx::query!(
            "INSERT INTO food_additive(food_id, additive) VALUES ($1, UNNEST($2::additive[]))",
            record.food_id,
            additives as _
        )
        .execute(&self.pool)
        .await?;

        // todo allergens
        // todo mealplan

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
