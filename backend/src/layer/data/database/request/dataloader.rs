use std::collections::HashMap;

use async_graphql::dataloader::Loader;
use sqlx::{Pool, Postgres};
use uuid::Uuid;

use crate::interface::persistent_data::model::{Image, Side};
use crate::interface::persistent_data::Result;
use crate::util::{FoodType, Price};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Line, Meal},
        DataError,
    },
    util::Date,
};

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
    }
}


pub(super) struct ManyMealsDataLoader(pub Pool<Postgres>);
#[derive(Clone, PartialEq, Eq, Hash, sqlx::Type)]
pub(super) struct LineDishKey {
    pub(super) line_id: Uuid,
    pub(super) serve_date: Date,
}
impl Loader<LineDishKey> for ManyMealsDataLoader {
    type Value = Vec<Meal>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[LineDishKey],
    ) -> std::result::Result<HashMap<LineDishKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
            SELECT food_id as "food_id!", name as "name!", food_type as "food_type!: FoodType",
                price_student, price_employee, price_guest, price_pupil, serve_date as date, line_id,
                new as "new!", frequency as "frequency!", last_served, next_served, average_rating as "average_rating!", rating_count as "rating_count!"
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE ROW(line_id, serve_date) IN (SELECT a, b FROM UNNEST($1::uuid[], $2::date[]) x(a,b))
            ORDER BY price_student DESC, food_type DESC, food_id
            "#,
            &keys.iter().map(|k| k.line_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.serve_date).collect::<Vec<_>>()
        )
        .fetch_all(&self.0)
        .await?
        .into_iter().try_fold( HashMap::<_,Vec<_>>::new(), |mut hmap, m| {
                hmap.entry(LineDishKey {line_id: m.line_id, serve_date: m.date}).or_default().push( 
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
                });

                Result::<_>::Ok(hmap)
        })
    }
}


pub(super) struct SidesLoader(pub Pool<Postgres>);
impl Loader<LineDishKey> for SidesLoader {
    type Value = Vec<Side>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[LineDishKey],
    ) -> std::result::Result<HashMap<LineDishKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
            SELECT line_id, serve_date, food_id, name, food_type as "food_type: FoodType", 
            price_student, price_employee, price_guest, price_pupil
            FROM food JOIN food_plan USING (food_id)
            WHERE ROW(line_id, serve_date) IN (SELECT a, b FROM UNNEST($1::uuid[], $2::date[]) x(a,b))
                AND food_id NOT IN (SELECT food_id FROM meal)
            ORDER BY food_id
            "#,
            &keys.iter().map(|k| k.line_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.serve_date).collect::<Vec<_>>()
        )
        .fetch_all(&self.0)
        .await?
        .into_iter()
        .try_fold( HashMap::<_,Vec<_>>::new(), |mut hmap, side| {
            hmap.entry(LineDishKey {line_id: side.line_id, serve_date: side.serve_date}).or_default().push( 
                Side {
                id: side.food_id,
                food_type: side.food_type,
                name: side.name,
                price: Price {
                    price_student: u32::try_from(side.price_student)?,
                    price_employee: u32::try_from(side.price_employee)?,
                    price_guest: u32::try_from(side.price_guest)?,
                    price_pupil: u32::try_from(side.price_pupil)?,
                },
            });
            Ok(hmap)
        })
    }
}


pub(super) struct ImageLoader(pub Pool<Postgres>);
impl Loader<Uuid> for ImageLoader {
    type Value = Vec<Image>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
                SELECT image_id as "image_id!", rank as "rank!", upvotes as "upvotes!", downvotes as "downvotes!", approved as "approved!", 
                    report_count as "report_count!", link_date as "upload_date!", food_id as "meal_id!", 
                    array_agg(r.user_id) FILTER (WHERE r.user_id IS NOT NULL) as "reporting_users!"
                FROM image_detail LEFT JOIN image_report r USING (image_id)
                WHERE currently_visible AND food_id = ANY ($1)
                GROUP BY image_id, rank, upvotes, downvotes, approved, report_count, link_date, food_id
                ORDER BY rank DESC, image_id
            "#,
            &keys
        )
        .fetch_all(&self.0)
        .await?
        .into_iter()
        .try_fold(HashMap::<_,Vec<_>>::new(), |mut h, m| {
            h.entry(  m.meal_id).or_default().push(
                Image {
                    id: m.image_id,
                    rank: m.rank,
                    upvotes: u32::try_from(m.upvotes)?,
                    downvotes: u32::try_from(m.downvotes)?,
                    approved: m.approved,
                    upload_date: m.upload_date,
                    report_count: u32::try_from(m.report_count)?,
                    meal_id: m.meal_id,
                    reporting_users: Some(m.reporting_users)
            });
            Ok(h)
        })
    }
}

