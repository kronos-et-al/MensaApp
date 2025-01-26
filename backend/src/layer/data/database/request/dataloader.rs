use std::collections::HashMap;

use async_graphql::dataloader::Loader;
use sqlx::{Pool, Postgres};
use uuid::Uuid;

use crate::interface::persistent_data::Result;
use crate::util::{FoodType, Price};

use crate::{interface::persistent_data::{model::{Canteen, Line, Meal}, DataError}, util::Date};




pub(super) struct CanteenDataloader(pub Pool<Postgres>);
impl Loader<Uuid> for CanteenDataloader {
    type Value = Canteen;
    type Error = DataError;
    async fn load( 
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query_as!(
            Canteen,
            "SELECT canteen_id as id, name FROM canteen WHERE canteen_id = ANY ($1)",
            keys
        )
        .fetch_all(&self.0)
        .await
        .map(|values| values.into_iter().map(|value| (value.id, value)).collect())
        .map_err(Into::into)
    }
}

pub(super) struct LineDataLoader(pub Pool<Postgres>);
impl Loader<Uuid> for LineDataLoader {
    type Value = Line;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query_as!(
            Line,
            "SELECT line_id as id, name, canteen_id FROM line WHERE line_id = ANY ($1)",
            keys
        )
        .fetch_all(&self.0)
        .await
        .map(|values| values.into_iter().map(|value| (value.id, value)).collect())
        .map_err(Into::into)
    }
}



pub(super) struct MealDataLoader(pub Pool<Postgres>);
#[derive(Clone, PartialEq, Eq, Hash, sqlx::Type)]
pub(super) struct MealKey {
    pub(super) food_id: Uuid,
    pub(super) line_id: Uuid,
    pub(super) serve_date: Date,
}
impl Loader<MealKey> for MealDataLoader {
    type Value = Meal;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[MealKey],
    ) -> std::result::Result<HashMap<MealKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
            SELECT food_id as "food_id!", name as "name!", food_type as "food_type!: FoodType",
                price_student, price_employee, price_guest, price_pupil, serve_date as date, line_id,
                new as "new!", frequency as "frequency!", last_served, next_served, average_rating as "average_rating!", rating_count as "rating_count!"
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE ROW(food_id, line_id, serve_date) IN (SELECT a, b, c FROM UNNEST($1::uuid[], $2::uuid[], $3::date[]) x(a,b,c))
            "#,
            &keys.iter().map(|k| k.food_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.line_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.serve_date).collect::<Vec<_>>()
        )
        .fetch_all(&self.0)
        .await?
        .into_iter()
        .map(|m| {
            Ok(( MealKey {food_id: m.food_id, line_id: m.line_id, serve_date: m.date}, 
                Meal {
                id: m.food_id,
                line_id: m.line_id,
                date: m.date,
                name: m.name,
                food_type: m.food_type,
                price: Price {
                    price_student: u32::try_from(m.price_student)?,
                    price_employee: u32::try_from(m.price_employee)?,
                    price_guest: u32::try_from(m.price_guest)?,
                    price_pupil: u32::try_from(m.price_pupil)?
                },
                frequency: u32::try_from(m.frequency)?,
                new: m.new,
                last_served: m.last_served,
                next_served: m.next_served,
                average_rating: m.average_rating,
                rating_count: u32::try_from(m.rating_count)?,
            }))
        })
        .collect::<Result<HashMap<_,_>>>()
        .map_err(Into::into)
    }
}