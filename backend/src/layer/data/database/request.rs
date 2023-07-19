use async_graphql::futures_util::TryFutureExt;
use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Image, Line, Meal, Side},
        DataError, RequestDataAccess, Result,
    },
    util::{Additive, Allergen, Date, Uuid},
};

/// Class implementing all database requests arising from graphql manipulations.
pub struct PersistentRequestData {
    pub(super) pool: Pool<Postgres>,
}

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
        todo!()
    }

    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>> {
        todo!()
    }

    async fn get_sides(&self, line_id: Uuid, date: Date) -> Result<Vec<Side>> {
        todo!()
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
        let res =
            res.map(|i| u32::try_from(i.rating).expect("rating violating database constrains"));
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
