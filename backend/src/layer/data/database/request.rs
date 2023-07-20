use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Image, Line, Meal, Side},
        DataError, RequestDataAccess, Result,
    },
    util::{Additive, Allergen, Date, MealType, Uuid},
};

use super::types::DatabasePrice;
/// Class implementing all database requests arising from graphql manipulations.
pub struct PersistentRequestData {
    pub(super) pool: Pool<Postgres>,
}

const DEFAULT_RATING: f32 = 5. / 2.;

#[async_trait]
impl RequestDataAccess for PersistentRequestData {
    async fn get_canteen(&self, id: Uuid) -> Result<Option<Canteen>> {
        sqlx::query_as!(
            Canteen,
            "SELECT canteen_id as id, name FROM canteen WHERE canteen_id = $1",
            id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_canteens(&self) -> Result<Vec<Canteen>> {
        sqlx::query_as!(Canteen, "SELECT canteen_id as id, name FROM canteen") // TODO canteen order
            .fetch_all(&self.pool)
            .await
            .map_err(Into::into)
    }

    async fn get_line(&self, id: Uuid) -> Result<Option<Line>> {
        sqlx::query_as!(
            Line,
            "SELECT line_id as id, name, canteen_id FROM line WHERE line_id = $1",
            id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_lines(&self, canteen_id: Uuid) -> Result<Vec<Line>> {
        sqlx::query_as!(
            Line,
            "SELECT line_id as id, name, canteen_id FROM line WHERE canteen_id = $1 ORDER BY position",
            canteen_id
        )
        .fetch_all(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_meal(&self, id: Uuid, line_id: Uuid, date: Date) -> Result<Option<Meal>> {
        let meal = sqlx::query!(
            r#"
            SELECT food_id as id, name, food_type as "meal_type: MealType",
                prices as "price: DatabasePrice", serve_date as date, line_id
            FROM meal JOIN food USING (food_id) JOIN food_plan USING (food_id)
            WHERE food_id = $1 AND line_id = $2 AND serve_date = $3
            "#,
            id,
            line_id,
            date
        )
        .fetch_optional(&self.pool)
        .await?;

        let Some(meal) = meal else {
            return Ok(None);
        };

        let statistics = sqlx::query!(
            "
            SELECT (COUNT(*) = 0) as new, 
            COUNT(*) FILTER (WHERE serve_date > CURRENT_DATE - 30 * 3) as frequency,
            MAX(serve_date) FILTER (WHERE serve_date < CURRENT_DATE) as last_served,
            MIN(serve_date) FILTER (WHERE serve_date > CURRENT_DATE) as next_served
            FROM food_plan WHERE food_id = $1",
            id
        )
        .fetch_one(&self.pool)
        .await?;

        let ratings = sqlx::query!(
            "
            SELECT AVG(rating::real)::real as average_rating, COUNT(*) as rating_count 
            FROM meal_rating 
            WHERE food_id = $1",
            id
        )
        .fetch_one(&self.pool)
        .await?;

        Ok(Some(Meal {
            id,
            date,
            line_id,
            name: meal.name,
            meal_type: meal.meal_type,
            price: meal.price.try_into()?,

            last_served: statistics.last_served,
            next_served: statistics.next_served,
            frequency: statistics.frequency.unwrap_or_default() as u32,
            new: statistics.new.unwrap_or_default(),

            rating_count: ratings.rating_count.unwrap_or_default() as u32,
            average_rating: ratings.average_rating.unwrap_or(DEFAULT_RATING),
        }))
    }

    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>> {
        todo!()
    }

    async fn get_sides(&self, line_id: Uuid, date: Date) -> Result<Vec<Side>> {
        let vec = sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "meal_type: MealType", prices as "price: DatabasePrice"
            FROM food JOIN food_plan USING (food_id)
            WHERE line_id = $1 AND serve_date = $2
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|side| Ok(Side {
            id: side.food_id, 
            meal_type: side.meal_type, 
            name: side.name, 
            price: side.price.try_into()? // todo remove silent error, find better solution
        },))
        .filter_map(Result::ok)
        .collect();

        Ok(vec)
    }

    async fn get_visible_images(
        &self,
        meal_id: Uuid,
        client_id: Option<Uuid>,
    ) -> Result<Vec<Image>> {
        todo!()
    }

    async fn get_personal_rating(&self, meal_id: Uuid, client_id: Uuid) -> Result<Option<u32>> {
        let res = sqlx::query!(
            "SELECT rating FROM meal_rating WHERE food_id = $1 AND user_id = $2",
            meal_id,
            client_id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::<DataError>::into)?;
        let res = res.map(|i| i.rating as u32);
        Ok(res)
    }

    async fn get_personal_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<bool> {
        sqlx::query!(
            "SELECT rating FROM image_rating WHERE image_id = $1 AND user_id = $2 AND rating = 1",
            image_id,
            client_id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::<DataError>::into)
        .map(|o| o.is_some())
    }

    async fn get_personal_downvote(&self, image_id: Uuid, client_id: Uuid) -> Result<bool> {
        sqlx::query!(
            "SELECT rating FROM image_rating WHERE image_id = $1 AND user_id = $2 AND rating = -1",
            image_id,
            client_id
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::<DataError>::into)
        .map(|o| o.is_some())
    }

    async fn get_additives(&self, food_id: Uuid) -> Result<Vec<Additive>> {
        let res = sqlx::query!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| r.additive)
        .collect();
        Ok(res)
    }

    async fn get_allergens(&self, food_id: Uuid) -> Result<Vec<Allergen>> {
        let res = sqlx::query!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| r.allergen)
        .collect();
        Ok(res)
    }
}
