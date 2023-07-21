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
#[derive(Debug)]
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
        .await?
        .and_then(|m| {
            Some(Meal {
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
                rating_count: m.rating_count? as u32,
            })
        });

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
        .await?
        .into_iter()
        .filter_map(|m| {
            Some(Meal {
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
                rating_count: m.rating_count? as u32,
            })
        })
        .collect();

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

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use super::*;
    use sqlx::PgPool;

    #[sqlx::test]
    async fn test_canteens(pool: PgPool) {
        provide_dummy_data(&pool).await;
        let request = PersistentRequestData { pool };

        let canteen = request.get_canteens().await.unwrap();
        assert!(canteen.len() == 3);
        assert!(canteen[0].name == "my favorite canteen");      //TODO: Canteen order
        assert!(canteen[1].name == "second canteen");
        assert!(canteen[2].name == "bad canteen");
    }

    #[sqlx::test]
    async fn test_canteen(pool: PgPool) {
        provide_dummy_data(&pool).await;
        let request = PersistentRequestData { pool };

        let canteen_id_strs = ["10728cc4-1e07-4e18-a9d9-ca45b9782413", "8f10c56d-da9b-4f62-b4c1-16feb0f98c67", "f2885f67-fc95-4205-bc7d-b2fb78cee0a8"];
        let mut canteens = Vec::new();
        for canteen_id_str in canteen_id_strs {
            if let Ok(canteen_id) = Uuid::parse_str(canteen_id_str) {
                if let Ok(Some(canteen)) = request.get_canteen(canteen_id).await {
                    canteens.push(canteen);
                }
            }
        }
        assert!(canteens.len() == 3);
        assert!(canteens[0].name == "my favorite canteen");      //TODO: Canteen order
        assert!(canteens[1].name == "second canteen");
        assert!(canteens[2].name == "bad canteen");
    }

    #[sqlx::test]
    async fn test_line(pool: PgPool) {
        provide_dummy_data(&pool).await;
        let request = PersistentRequestData { pool };

        let lines = request.get_lines(Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap()).await.unwrap();
        assert!(lines.len() == 3);
        assert!(lines[0].name == "line 1");
        assert!(lines[1].name == "line 2");
        assert!(lines[2].name == "special line");
    }

    #[sqlx::test]
    async fn test_meals(pool: PgPool) {
        provide_dummy_data(&pool).await;
        let request = PersistentRequestData { pool };

        let meals = request.get_meals(Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(), Date::parse_from_str("2023-07-10", "%Y-%m-%d").unwrap()).await.unwrap();
        if let Some(meals) = meals {
            assert!(meals.len() == 2);
            assert!(meals[0].name == "Geflügel - Cevapcici, Ajvar, Djuvec Reis");
            assert!(meals[1].name == "2 Dampfnudeln mit Vanillesoße");
        }
    }

    #[sqlx::test]
    async fn test_sides(pool: PgPool) {
        provide_dummy_data(&pool).await;
        let request = PersistentRequestData { pool };

        let sides = request.get_sides(Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(), Date::parse_from_str("2023-07-10", "%Y-%m-%d").unwrap()).await.unwrap();
        assert!(sides.len() == 1);
        assert!(sides[0].name == "zu jedem Gericht reichen wir ein Dessert oder Salat");
    }

    async fn provide_dummy_data(pool: &PgPool) {
        const INSERT_FAILED: &str = "failed to insert";

        sqlx::query!("INSERT INTO canteen(canteen_id, name) VALUES 
        ('10728cc4-1e07-4e18-a9d9-ca45b9782413', 'my favorite canteen'), 
        ('8f10c56d-da9b-4f62-b4c1-16feb0f98c67', 'second canteen'), 
        ('f2885f67-fc95-4205-bc7d-b2fb78cee0a8', 'bad canteen')")
            .execute(pool)
            .await
            .expect(INSERT_FAILED);


        sqlx::query!("INSERT INTO line(line_id, canteen_id, name, position) VALUES 
        ('61b27158-817c-4716-bd41-2a8901391ea4', '10728cc4-1e07-4e18-a9d9-ca45b9782413', 'line 2', 2), 
        ('3e8c11fa-906a-4c6a-bc71-28756c6b00ae', '10728cc4-1e07-4e18-a9d9-ca45b9782413', 'line 1', 1), 
        ('a4956171-a5fc-4c6b-a028-3cb2e5d2bedb', '10728cc4-1e07-4e18-a9d9-ca45b9782413', 'special line', 3),
        ('119c55b7-e539-4849-bad1-984efff2aad6', '8f10c56d-da9b-4f62-b4c1-16feb0f98c67', 'single line', 0)")
            .execute(pool)
            .await
            .expect(INSERT_FAILED);

        sqlx::query!("INSERT INTO food(food_id, name, food_type) 
        VALUES ('f7337122-b018-48ad-b420-6202dc3cb4ff', 'Geflügel - Cevapcici, Ajvar, Djuvec Reis', 'UNKNOWN'),
        ('73cf367b-a536-4b49-ad0c-cb984caa9a08', 'zu jedem Gericht reichen wir ein Dessert oder Salat', 'UNKNOWN'),
        ('25cb8c50-75a4-48a2-b4cf-8ab2566d8bec', '2 Dampfnudeln mit Vanillesoße', 'VEGETARIAN'),
        ('0a850476-eda4-4fd8-9f93-579eb85b8c25', 'Mediterraner Gemüsegulasch mit Räuchertofu, dazu Sommerweizen', 'VEGAN'),
        ('1b5633c2-05c5-4444-90e5-2e475bae6463', 'Cordon bleu vom Schwein mit Bratensoße', 'PORK')")
            .execute(pool)
            .await
            .expect(INSERT_FAILED);    

        sqlx::query!("INSERT INTO food_plan(line_id, food_id, serve_date, prices)
        VALUES  ('3e8c11fa-906a-4c6a-bc71-28756c6b00ae', 'f7337122-b018-48ad-b420-6202dc3cb4ff', '2023-07-10', (320,420,460,355)),
                ('3e8c11fa-906a-4c6a-bc71-28756c6b00ae', '73cf367b-a536-4b49-ad0c-cb984caa9a08', '2023-07-10', (0,0,0,0)),
                ('3e8c11fa-906a-4c6a-bc71-28756c6b00ae', '25cb8c50-75a4-48a2-b4cf-8ab2566d8bec', '2023-07-10', (320,420,460,355)),
                ('61b27158-817c-4716-bd41-2a8901391ea4', '0a850476-eda4-4fd8-9f93-579eb85b8c25', '2023-07-10', (350,520,770,405))")
                .execute(pool)
                .await
                .expect(INSERT_FAILED);

        sqlx::query!("INSERT INTO meal(food_id)
        VALUES  ('f7337122-b018-48ad-b420-6202dc3cb4ff'),
                ('25cb8c50-75a4-48a2-b4cf-8ab2566d8bec'),
                ('0a850476-eda4-4fd8-9f93-579eb85b8c25'),
                ('1b5633c2-05c5-4444-90e5-2e475bae6463')")
                .execute(pool)
                .await
                .expect(INSERT_FAILED);

    }
}
