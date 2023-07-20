use std::num::TryFromIntError;

use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Line, Meal, Side},
        MealplanManagementDataAccess, Result,
    },
    util::{Additive, Allergen, Date, MealType, Price, Uuid},
};

#[derive(sqlx::Type)]
#[sqlx(type_name = "prices")]
struct DatabasePrice {
    /// Price of the dish for students.
    pub student: i32,
    /// Price of the dish for employees.
    pub employee: i32,
    /// Price of the dish for guests.
    pub guest: i32,
    /// Price of the dish for pupils.
    pub pupil: i32,
}

impl TryFrom<DatabasePrice> for Price {
    type Error = TryFromIntError;

    fn try_from(value: DatabasePrice) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            price_student: value.student.try_into()?,
            price_employee: value.employee.try_into()?,
            price_guest: value.guest.try_into()?,
            price_pupil: value.pupil.try_into()?,
        })
    }
}

impl TryFrom<Price> for DatabasePrice {
    type Error = TryFromIntError;

    fn try_from(value: Price) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            student: value.price_student.try_into()?,
            employee: value.price_employee.try_into()?,
            guest: value.price_guest.try_into()?,
            pupil: value.price_pupil.try_into()?,
        })
    }
}

pub struct PersistentMealplanManagementData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
impl MealplanManagementDataAccess for PersistentMealplanManagementData {
    async fn dissolve_relations(&self, canteen: Canteen, date: Date) -> Result<()> {
        let line_ids = sqlx::query!(
            "SELECT line_id
        FROM line
        WHERE canteen_id = $1",
            canteen.id
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|record| record.line_id);
        for line_id in line_ids {
            sqlx::query!(
                "DELETE FROM food_plan
                WHERE serve_date = $1
                AND line_id = $2",
                date,
                line_id
            )
            .execute(&self.pool)
            .await?;
        }
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
            "UPDATE canteen 
            SET canteen_id = $1, name = $2
            RETURNING canteen_id as id, name ",
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
            "UPDATE line 
            SET line_id = $1, name = $2 
            RETURNING line_id as id, name, canteen_id",
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
        /*
        let price_test = sqlx::query!(
            "UPDATE food_plan
        SET prices = '(1, 2, 3, 4)'
        WHERE food_id = $1
          AND line_id = $2
          AND serve_date = $3
        RETURNING prices",
            uuid,
            line_id,
            date
        )
        .fetch_one(&self.pool)
        .await?;

        let price = price_test.prices;
        let side_test = sqlx::query!(
            r#"UPDATE food
            SET name = $1
            WHERE food_id = $2
            RETURNING food_id as id, name, food_type as "food_type: MealType""#,
            name,
            uuid,
        )
        .fetch_one(&self.pool)
        .await?;
        Ok(Side {
            id: side_test.id,
            name: side_test.name,
            meal_type: side_test.food_type,
            price,
        })
         */
        todo!()
    }

    async fn insert_canteen(&self, name: &str) -> Result<Canteen> {
        sqlx::query_as!(
            Canteen,
            "INSERT INTO canteen (name) 
            VALUES ($1) 
            RETURNING canteen_id as id, name ",
            name
        )
        .fetch_one(&self.pool)
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
