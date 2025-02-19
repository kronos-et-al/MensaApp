use std::collections::HashMap;

use async_graphql::dataloader::Loader;
use futures::{StreamExt, TryStreamExt};
use sqlx::{Pool, Postgres};
use uuid::Uuid;

use crate::interface::persistent_data::model::{EnvironmentInfo, Image, Side};
use crate::util::{Additive, Allergen, FoodType, NutritionData, Price};

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
        .fetch(&self.0)
        .map(|value| {
            let value = value?;
            Ok((value.id, value))
        })
        .try_collect()
        .await
    }
}
impl Loader<()> for CanteenDataloader {
    type Value = Vec<Canteen>;
    type Error = DataError;
    async fn load(
        &self,
        _keys: &[()],
    ) -> std::result::Result<HashMap<(), Self::Value>, Self::Error> {
        let canteens = sqlx::query_as!(
            Canteen,
            "SELECT canteen_id as id, name FROM canteen ORDER BY position"
        )
        .fetch_all(&self.0)
        .await?;
        Ok(HashMap::from([((), canteens)]))
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
        .fetch(&self.0)
        .map(|value| {
            let value = value?;
            Ok((value.id, value))
        })
        .try_collect()
        .await
    }
}

pub(super) struct CanteenLinesLoader(pub Pool<Postgres>);
impl Loader<Uuid> for CanteenLinesLoader {
    type Value = Vec<Line>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query_as!(Line,
            "SELECT line_id as id, name, canteen_id FROM line WHERE canteen_id = ANY($1) ORDER BY position",
            keys
        )
        .fetch(&self.0).try_fold(HashMap::<_,Vec<_>>::new(), |mut h, m| async move {
            h.entry(m.canteen_id).or_default().push(m);
            Ok(h)
        }).await.map_err(Into::into)
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
                price_student, price_employee, price_guest,
                price_pupil, serve_date as date, line_id, new as "new!",
                frequency as "frequency!", last_served, next_served, average_rating as "average_rating!", rating_count as "rating_count!"
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE ROW(food_id, line_id, serve_date) IN (SELECT a, b, c FROM UNNEST($1::uuid[], $2::uuid[], $3::date[]) x(a,b,c))
            "#,
            &keys.iter().map(|k| k.food_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.line_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.serve_date).collect::<Vec<_>>()
        )
        .fetch(&self.0)
        .map(|m| {
            let m = m?;
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
        .try_collect().await
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
        .fetch(&self.0)
        .map_err(DataError::from)
        .try_fold( HashMap::<_,Vec<_>>::new(), |mut hmap, m| async move{
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

                Ok(hmap)
        }).await
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
        .fetch(&self.0)
        .map_err(DataError::from)
        .try_fold( HashMap::<_,Vec<_>>::new(), |mut hmap, side| async move {
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
        }).await
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
                    COALESCE(array_agg(r.user_id) FILTER (WHERE r.user_id IS NOT NULL), ARRAY[]::uuid[]) as "reporting_users!"
                FROM image_detail LEFT JOIN image_report r USING (image_id)
                WHERE currently_visible AND food_id = ANY ($1)
                GROUP BY image_id, rank, upvotes, downvotes, approved, report_count, link_date, food_id
                ORDER BY rank DESC, image_id
            "#,
            &keys
        )
        .fetch(&self.0)
        .map_err(DataError::from)
        .try_fold(HashMap::<_,Vec<_>>::new(), |mut h, m| async move {
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
                    reporting_users: Some(m.reporting_users) // todo maybe put into outer tuple instead modifying image struct and carrying these additional arrays everywhere. Overhead?
            });
            Ok(h)
        }).await
    }
}

pub(super) struct RatingLoader(pub Pool<Postgres>);
#[derive(Clone, PartialEq, Eq, Hash, sqlx::Type)]
pub(super) struct RatingKey {
    pub(super) food_id: Uuid,
    pub(super) user_id: Uuid,
}
impl Loader<RatingKey> for RatingLoader {
    type Value = u32;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[RatingKey],
    ) -> std::result::Result<HashMap<RatingKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT rating, food_id, user_id FROM meal_rating
               WHERE ROW(food_id, user_id) IN (SELECT food_id, user_id FROM UNNEST($1::uuid[], $2::uuid[]) x(food_id, user_id))
            "#,
            &keys.iter().map(|k| k.food_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.user_id).collect::<Vec<_>>()
        )
        .fetch(&self.0).map(|k| {
            let k = k?;
            Ok((RatingKey{food_id: k.food_id, user_id: k.user_id}, u32::try_from(k.rating)?))
        }).try_collect()
        .await
    }
}

pub(super) struct ImageVoteLoader(pub Pool<Postgres>);
#[derive(Clone, PartialEq, Eq, Hash, sqlx::Type)]
pub(super) struct UpvoteKey {
    pub(super) image_id: Uuid,
    pub(super) user_id: Uuid,
}
impl Loader<UpvoteKey> for ImageVoteLoader {
    type Value = ();
    type Error = DataError;
    async fn load(
        &self,
        keys: &[UpvoteKey],
    ) -> std::result::Result<HashMap<UpvoteKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT image_id, user_id FROM image_rating
               WHERE rating = 1 AND ROW(image_id, user_id) IN (SELECT a, b FROM UNNEST($1::uuid[], $2::uuid[]) x(a, b))
            "#,
            &keys.iter().map(|k| k.image_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.user_id).collect::<Vec<_>>()
        )
        .fetch(&self.0).map(|k| {
            let k = k?;
            Ok((UpvoteKey{image_id: k.image_id, user_id: k.user_id}, ()))
        }).try_collect()
        .await
    }
}
#[derive(Clone, PartialEq, Eq, Hash, sqlx::Type)]
pub(super) struct DownvoteKey {
    pub(super) image_id: Uuid,
    pub(super) user_id: Uuid,
}
impl Loader<DownvoteKey> for ImageVoteLoader {
    type Value = ();
    type Error = DataError;
    async fn load(
        &self,
        keys: &[DownvoteKey],
    ) -> std::result::Result<HashMap<DownvoteKey, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT image_id, user_id FROM image_rating
               WHERE rating = -1 AND ROW(image_id, user_id) IN (SELECT a, b FROM UNNEST($1::uuid[], $2::uuid[]) x(a, b))
            "#,
            &keys.iter().map(|k| k.image_id).collect::<Vec<_>>(),
            &keys.iter().map(|k| k.user_id).collect::<Vec<_>>()
        )
        .fetch(&self.0).map(|k| {
            let k = k?;
            Ok((DownvoteKey{image_id: k.image_id, user_id: k.user_id}, ()))
        }).try_collect()
        .await
    }
}

pub(super) struct AdditiveLoader(pub Pool<Postgres>);
impl Loader<Uuid> for AdditiveLoader {
    type Value = Vec<Additive>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT food_id, additive as "additive: Additive" FROM food_additive WHERE food_id = ANY ($1) ORDER BY additive
            "#,
            &keys
        )
        .fetch(&self.0)
        .try_fold(HashMap::<_,Vec<_>>::new(), |mut h, m| async move {
            h.entry(  m.food_id).or_default().push(m.additive);
            Ok(h)
        }).await.map_err(Into::into)
    }
}

pub(super) struct AllergenLoader(pub Pool<Postgres>);
impl Loader<Uuid> for AllergenLoader {
    type Value = Vec<Allergen>;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT food_id, allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = ANY ($1) ORDER BY allergen
            "#,
            &keys
        )
        .fetch(&self.0)
        .try_fold(HashMap::<_,Vec<_>>::new(), |mut h, m| async move {
            h.entry(  m.food_id).or_default().push(m.allergen);
            Ok(h)
        }).await.map_err(Into::into)
    }
}
pub(super) struct NutritionDataLoader(pub Pool<Postgres>);
impl Loader<Uuid> for NutritionDataLoader {
    type Value = NutritionData;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT food_id, energy, protein, carbohydrates, sugar, fat, saturated_fat, salt FROM food_nutrition_data WHERE food_id = ANY($1)
            "#,
            &keys
        )
        .fetch(&self.0)
        .map(|k| {let k = k?; Ok((k.food_id, NutritionData{
            carbohydrates: u32::try_from(k.carbohydrates)?,
            energy: u32::try_from(k.energy)?,
            fat: u32::try_from(k.fat)?,
            protein: u32::try_from(k.protein)?,
            salt: u32::try_from(k.salt)?,
            saturated_fat: u32::try_from(k.saturated_fat)?,
            sugar: u32::try_from(k.sugar)?,
        }))}).try_collect().await
    }
}
pub(super) struct EnvironmentInfoLoader(pub Pool<Postgres>);
impl Loader<Uuid> for EnvironmentInfoLoader {
    type Value = EnvironmentInfo;
    type Error = DataError;
    async fn load(
        &self,
        keys: &[Uuid],
    ) -> std::result::Result<HashMap<Uuid, Self::Value>, Self::Error> {
        sqlx::query!(
            r#"
               SELECT food_id, co2_rating, co2_value, water_rating, water_value, animal_welfare_rating, rainforest_rating, max_rating FROM food_env_score WHERE food_id = ANY($1)
            "#,
            &keys
        )
        .fetch(&self.0)
        .map(|k| {
            let k = k?;
            let co2_rating = u32::try_from(k.co2_rating)?;
            let water_rating = u32::try_from(k.water_rating)?;
            let animal_welfare_rating = u32::try_from(k.animal_welfare_rating)?;
            let rainforest_rating = u32::try_from(k.rainforest_rating)?;
            let average_rating =
                (co2_rating + water_rating + animal_welfare_rating + rainforest_rating) / 4;
            Ok((k.food_id, EnvironmentInfo{
                    animal_welfare_rating,
                    average_rating,
                    co2_rating,
                    co2_value: u32::try_from(k.co2_value)?,
                    rainforest_rating,
                    water_rating,
                    water_value: u32::try_from(k.water_value)?,
                    max_rating: u32::try_from(k.max_rating)?,
                }))
        }).try_collect().await
    }
}
