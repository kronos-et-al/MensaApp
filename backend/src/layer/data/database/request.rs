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
            SELECT food_id, name, food_type as "meal_type: MealType",
                prices as "price: DatabasePrice", serve_date as date, line_id,
                new, frequency, last_served, next_served, average_rating, rating_count
            FROM meal_detail
            WHERE food_id = $1 AND line_id = $2 AND serve_date = $3
            "#,
            id,
            line_id,
            date
        )
        .fetch_optional(&self.pool)
        .await?.and_then(|m| Some(Meal {
            id: m.food_id?,
            line_id: m.line_id?,
            date: m.date?,
            name: m.name?,
            meal_type: m.meal_type?,
            price: m.price?.try_into().ok()?,
            frequency: m.frequency? as u32,
            new: m.new?,
            last_served: m.last_served,
            next_served: m.next_served,
            average_rating: m.average_rating.unwrap_or(DEFAULT_RATING),
            rating_count: m.rating_count? as u32

        }));

        Ok(meal)
    }

    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>> {
        // todo return none when no data exists (to far in future)
        let meal = sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "meal_type: MealType",
                prices as "price: DatabasePrice", serve_date as date, line_id,
                new, frequency, last_served, next_served, average_rating, rating_count
            FROM meal_detail
            WHERE line_id = $1 AND serve_date = $2
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?.into_iter().filter_map(|m| Some(Meal {
            id: m.food_id?,
            line_id: m.line_id?,
            date: m.date?,
            name: m.name?,
            meal_type: m.meal_type?,
            price: m.price?.try_into().ok()?,
            frequency: m.frequency? as u32,
            new: m.new?,
            last_served: m.last_served,
            next_served: m.next_served,
            average_rating: m.average_rating.unwrap_or(DEFAULT_RATING),
            rating_count: m.rating_count? as u32

        })).collect();

        Ok(Some(meal))
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
        .filter_map(|side| Some(Side {
            id: side.food_id, 
            meal_type: side.meal_type, 
            name: side.name, 
            price: side.price.try_into().ok()? // todo remove silent error, find better solution; maybe even panic as this should never occur and this we should notice?
        }))
        .collect();

        Ok(vec)
    }

    async fn get_visible_images(
        &self,
        meal_id: Uuid,
        client_id: Option<Uuid>,
    ) -> Result<Vec<Image>> {
        let images = sqlx::query!(
            "
            SELECT image_id as id, id as image_hoster_id, url, rank, downvotes, upvotes FROM (
                SELECT image_id 
                FROM image JOIN image_report r USING (image_id)
                WHERE currently_visible AND food_id = $1
                GROUP BY image_id
                HAVING COUNT(*) FILTER (WHERE r.user_id = $2) = 0
            ) not_reported JOIN image_detail USING (image_id)
            ",
            meal_id,
            client_id
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .filter_map(|r| {
            Some(Image {
                id: r.id,
                url: r.url?,
                rank: r.rank?,
                image_hoster_id: r.image_hoster_id?,
                downvotes: r.downvotes? as u32,
                upvotes: r.upvotes? as u32,
            })
        })
        .collect();
        Ok(images)
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
