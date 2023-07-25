use async_trait::async_trait;
use chrono::{DateTime, Local};
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, Image, Line, Meal, Side},
        DataError, RequestDataAccess, Result,
    },
    util::{Additive, Allergen, Date, MealType, Price, Uuid},
};

const MAX_WEEKS_DATA: i64 = 4;

/// Class implementing all database requests arising from graphql manipulations.
#[derive(Debug)]
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
        sqlx::query_as!(
            Canteen,
            "SELECT canteen_id as id, name FROM canteen ORDER BY position"
        )
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
                price_student, price_employee, price_guest, price_pupil, serve_date as date, line_id,
                new, frequency, last_served, next_served, average_rating, rating_count
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE food_id = $1 AND line_id = $2 AND serve_date = $3
            "#,
            id,
            line_id,
            date
        )
        .fetch_optional(&self.pool)
        .await?
        .and_then(|m| {
            Some(Meal {
                id: m.food_id?,
                line_id: m.line_id,
                date: m.date,
                name: m.name?,
                meal_type: m.meal_type?,
                price: Price {
                    price_student: m.price_student as u32,
                    price_employee: m.price_employee as u32,
                    price_guest: m.price_guest as u32,
                    price_pupil: m.price_pupil as u32
                },
                frequency: m.frequency? as u32,
                new: m.new?,
                last_served: m.last_served,
                next_served: m.next_served,
                average_rating: m.average_rating?,
                rating_count: m.rating_count? as u32,
            })
        });

        Ok(meal)
    }

    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>> {
        // If date too far into the future, return `None`.
        // This should probably be inside the logic layer which currently does not exists for request.
        let today = Local::now().date_naive();
        let age = today - date;
        if age.num_weeks() > MAX_WEEKS_DATA {
            return Ok(None);
        }

        let meal = sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "meal_type: MealType",
                price_student, price_employee, price_guest, price_pupil, serve_date as date, line_id,
                new, frequency, last_served, next_served, average_rating, rating_count
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE line_id = $1 AND serve_date = $2
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .filter_map(|m| {
            Some(Meal {
                id: m.food_id?,
                line_id: m.line_id,
                date: m.date,
                name: m.name?,
                meal_type: m.meal_type?,
                price: Price {
                    price_student: m.price_student as u32,
                    price_employee: m.price_employee as u32,
                    price_guest: m.price_guest as u32,
                    price_pupil: m.price_pupil as u32
                },
                frequency: m.frequency? as u32,
                new: m.new?,
                last_served: m.last_served,
                next_served: m.next_served,
                average_rating: m.average_rating?,
                rating_count: m.rating_count? as u32,
            })
        })
        .collect();

        Ok(Some(meal))
    }

    async fn get_sides(&self, line_id: Uuid, date: Date) -> Result<Vec<Side>> {
        let vec = sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "meal_type: MealType", 
            price_student, price_employee, price_guest, price_pupil
            FROM food JOIN food_plan USING (food_id)
            WHERE line_id = $1 AND serve_date = $2 AND food_id NOT IN (SELECT food_id FROM meal)
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|side| {
            Side {
                id: side.food_id,
                meal_type: side.meal_type,
                name: side.name,
                price: Price {
                    price_student: side.price_student as u32,
                    price_employee: side.price_employee as u32,
                    price_guest: side.price_guest as u32,
                    price_pupil: side.price_pupil as u32,
                }, // todo remove silent error, find better solution; maybe even panic as this should never occur and this we should notice?
            }
        })
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
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date 
            FROM (
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
                id: r.image_id?,
                url: r.url?,
                rank: r.rank?,
                image_hoster_id: r.hoster_id?,
                downvotes: r.downvotes? as u32,
                upvotes: r.upvotes? as u32,
                approved: r.approved?,
                report_count: r.report_count? as _,
                upload_date: r.link_date?,
            })
        })
        .collect();
        Ok(images)
    }

    async fn get_personal_rating(&self, meal_id: Uuid, client_id: Uuid) -> Result<Option<u32>> {
        let res = sqlx::query_scalar!(
            "SELECT rating FROM meal_rating WHERE food_id = $1 AND user_id = $2",
            meal_id,
            client_id
        )
        .fetch_optional(&self.pool)
        .await?;
        let res = res.map(|i| i as u32);
        Ok(res)
    }

    async fn get_personal_upvote(&self, image_id: Uuid, client_id: Uuid) -> Result<bool> {
        sqlx::query_scalar!(
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
        sqlx::query_scalar!(
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
        let res = sqlx::query_scalar!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?;
        Ok(res)
    }

    async fn get_allergens(&self, food_id: Uuid) -> Result<Vec<Allergen>> {
        let res = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?;
        Ok(res)
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use super::*;
    use futures::future;
    use sqlx::PgPool;

    #[sqlx::test(fixtures("canteen"))]
    async fn test_get_canteen(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let canteen_id_strs = [
            "10728cc4-1e07-4e18-a9d9-ca45b9782413",
            "8f10c56d-da9b-4f62-b4c1-16feb0f98c67",
            "f2885f67-fc95-4205-bc7d-b2fb78cee0a8",
        ];

        let canteen_ids = canteen_id_strs
            .into_iter()
            .filter_map(|canteen_id_str| Uuid::parse_str(canteen_id_str).ok());
        let canteens: Vec<Canteen> =
            future::join_all(canteen_ids.map(|canteen_id| request.get_canteen(canteen_id)))
                .await
                .into_iter()
                .flatten()
                .flatten()
                .collect();
        assert!(canteens.len() == 3);
        assert_eq!(canteens[0].name, "my favorite canteen"); //TODO: Canteen order
        assert_eq!(canteens[1].name, "second canteen");
        assert_eq!(canteens[2].name, "bad canteen");
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_get_canteens(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let canteen = request.get_canteens().await.unwrap();
        assert!(canteen.len() == 3);
        assert_eq!(canteen[0].name, "my favorite canteen"); //TODO: Canteen order
        assert_eq!(canteen[1].name, "second canteen");
        assert_eq!(canteen[2].name, "bad canteen");
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_get_line(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let lines = request
            .get_lines(Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap())
            .await
            .unwrap();
        assert!(lines.len() == 3);
        assert_eq!(lines[0].name, "line 1");
        assert_eq!(lines[1].name, "line 2");
        assert_eq!(lines[2].name, "special line");
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_get_lines(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let line_id_strs = [
            "3e8c11fa-906a-4c6a-bc71-28756c6b00ae",
            "61b27158-817c-4716-bd41-2a8901391ea4",
            "a4956171-a5fc-4c6b-a028-3cb2e5d2bedb",
        ];
        let mut lines = Vec::new();
        for line_id_str in line_id_strs {
            if let Ok(line_id) = Uuid::parse_str(line_id_str) {
                if let Ok(Some(line)) = request.get_line(line_id).await {
                    lines.push(line);
                }
            }
        }
        assert!(lines.len() == 3);
        assert!(lines[0].name == "line 1");
        assert!(lines[1].name == "line 2");
        assert!(lines[2].name == "special line");
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_get_meal(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let meal_id_strs = [
            "73cf367b-a536-4b49-ad0c-cb984caa9a08",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
        ];
        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();
        let date = Date::parse_from_str("2023-07-10", "%Y-%m-%d").unwrap();
        let mut meals = Vec::new();
        for meal_id_str in meal_id_strs {
            let meal_id = Uuid::parse_str(meal_id_str).unwrap();
            if let Ok(Some(meal)) = request.get_meal(meal_id, line_id, date).await {
                meals.push(meal);
            }
        }
        dbg!(&meals);
        assert!(meals.len() == 2);
        assert!(meals[0].name == "Geflügel - Cevapcici, Ajvar, Djuvec Reis");
        assert!(meals[1].name == "2 Dampfnudeln mit Vanillesoße");
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_get_meals(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let meals = request
            .get_meals(
                Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(),
                Date::parse_from_str("2023-07-10", "%Y-%m-%d").unwrap(),
            )
            .await
            .unwrap();
        assert!(meals.is_some(), "data should ba available");
        let meals = meals.unwrap();
        let meal_names: Vec<&str> = meals.iter().map(|m| m.name.as_str()).collect();
        assert!(meals.len() == 2);
        assert!(meal_names.contains(&"Geflügel - Cevapcici, Ajvar, Djuvec Reis"));
        assert!(meal_names.contains(&"2 Dampfnudeln mit Vanillesoße"));
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_get_sides(pool: PgPool) {
        let request = PersistentRequestData { pool };

        let sides = request
            .get_sides(
                Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(),
                Date::parse_from_str("2023-07-10", "%Y-%m-%d").unwrap(),
            )
            .await
            .unwrap();
        assert!(sides.len() == 1);
        assert!(sides[0].name == "zu jedem Gericht reichen wir ein Dessert oder Salat");
    }
}
