//! Module responsible for handling database requests for api requests.

mod dataloader;

use async_graphql::dataloader::DataLoader;
use async_trait::async_trait;
use chrono::{Duration, Local};
use dataloader::{CanteenDataloader, LineDataLoader, MealDataLoader, MealKey};
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{
        model::{Canteen, EnvironmentInfo, Image, Line, Meal, Side},
        DataError, RequestDataAccess, Result,
    },
    null_error,
    util::{Additive, Allergen, Date, FoodType, NutritionData, Price, Uuid},
};

/// Class implementing all database requests arising from graphql manipulations.
pub struct PersistentRequestData {
    pool: Pool<Postgres>,
    /// Number of weeks, including the current week, we get/have data for.
    max_weeks_data: u32,
    canteen_loader: DataLoader<CanteenDataloader>,
    line_loader: DataLoader<LineDataLoader>,
    meal_loader: DataLoader<MealDataLoader>,
}

impl PersistentRequestData {
    /// Cereates a new [`PersistantRequestData`] object including dataloaders.
    #[must_use]
    pub fn new(pool: Pool<Postgres>, max_weeks_data: u32) -> Self {
        Self {
            max_weeks_data,
            canteen_loader: DataLoader::new(CanteenDataloader(pool.clone()), tokio::spawn),
            line_loader: DataLoader::new(LineDataLoader(pool.clone()), tokio::spawn),
            meal_loader: DataLoader::new(MealDataLoader(pool.clone()), tokio::spawn),
            pool,
        }
    }
}

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl RequestDataAccess for PersistentRequestData {
    async fn get_canteen(&self, id: Uuid) -> Result<Option<Canteen>> {
        self.canteen_loader.load_one(id).await
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
        self.line_loader.load_one(id).await
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
        self.meal_loader
            .load_one(MealKey {
                food_id: id,
                line_id,
                serve_date: date,
            })
            .await
    }

    async fn get_meals(&self, line_id: Uuid, date: Date) -> Result<Option<Vec<Meal>>> {
        // If date too far into the future, return `None`.
        // This should probably be inside the logic layer which currently does not exists for request.
        let today = Local::now().date_naive();
        let first_unknown_day = today.week(chrono::Weekday::Mon).first_day()
            + Duration::weeks(i64::from(self.max_weeks_data));
        if date >= first_unknown_day {
            return Ok(None);
        }

        // If date is to far in the past, return `None`.
        let first_date = sqlx::query_scalar!("SELECT MIN(serve_date) FROM food_plan")
            .fetch_one(&self.pool)
            .await?;
        if first_date.map_or(true, |first_date| first_date > date) {
            return Ok(None);
        }

        sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "food_type: FoodType",
                price_student, price_employee, price_guest, price_pupil, serve_date as date, line_id,
                new, frequency, last_served, next_served, average_rating, rating_count
            FROM meal_detail JOIN food_plan USING (food_id)
            WHERE line_id = $1 AND serve_date = $2
            ORDER BY price_student DESC, food_type DESC, food_id
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|m| {
            Ok(Meal {
                id: null_error!(m.food_id),
                line_id: m.line_id,
                date: m.date,
                name: null_error!(m.name),
                food_type: null_error!(m.food_type),
                price: Price {
                    price_student: u32::try_from(m.price_student)?,
                    price_employee: u32::try_from(m.price_employee)?,
                    price_guest: u32::try_from(m.price_guest)?,
                    price_pupil: u32::try_from(m.price_pupil)?
                },
                frequency: u32::try_from(null_error!(m.frequency))?,
                new: null_error!(m.new),
                last_served: m.last_served,
                next_served: m.next_served,
                average_rating: null_error!(m.average_rating),
                rating_count: u32::try_from(null_error!(m.rating_count))?,
            })
        })
        .collect::<Result<Vec<_>>>().map(Some)
    }

    async fn get_sides(&self, line_id: Uuid, date: Date) -> Result<Vec<Side>> {
        sqlx::query!(
            r#"
            SELECT food_id, name, food_type as "food_type: FoodType", 
            price_student, price_employee, price_guest, price_pupil
            FROM food JOIN food_plan USING (food_id)
            WHERE line_id = $1 AND serve_date = $2 AND food_id NOT IN (SELECT food_id FROM meal)
            ORDER BY food_id
            "#,
            line_id,
            date
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|side| {
            Ok(Side {
                id: side.food_id,
                food_type: side.food_type,
                name: side.name,
                price: Price {
                    price_student: u32::try_from(side.price_student)?,
                    price_employee: u32::try_from(side.price_employee)?,
                    price_guest: u32::try_from(side.price_guest)?,
                    price_pupil: u32::try_from(side.price_pupil)?,
                },
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_visible_images(
        &self,
        meal_id: Uuid,
        client_id: Option<Uuid>,
    ) -> Result<Vec<Image>> {
        sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date, food_id
            FROM (
                --- not reported by user
                SELECT image_id 
                FROM image LEFT JOIN image_report r USING (image_id)
                GROUP BY image_id
                HAVING COUNT(*) FILTER (WHERE r.user_id = $2) = 0
            ) not_reported JOIN image_detail USING (image_id)
            WHERE currently_visible AND food_id = $1
            ORDER BY rank DESC, image_id
            ",
            meal_id,
            client_id
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| {
            Ok(Image {
                id: r.image_id,
                rank: null_error!(r.rank),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
                meal_id: null_error!(r.food_id),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_personal_rating(&self, meal_id: Uuid, client_id: Uuid) -> Result<Option<u32>> {
        let res = sqlx::query_scalar!(
            "SELECT rating FROM meal_rating WHERE food_id = $1 AND user_id = $2",
            meal_id,
            client_id
        )
        .fetch_optional(&self.pool)
        .await?;

        res.map(u32::try_from).transpose().map_err(Into::into)
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
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1 ORDER BY additive"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?;
        Ok(res)
    }

    async fn get_allergens(&self, food_id: Uuid) -> Result<Vec<Allergen>> {
        let res = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1 ORDER BY allergen"#,
            food_id
        )
        .fetch_all(&self.pool)
        .await?;
        Ok(res)
    }

    async fn get_nutrition_data(&self, food_id: Uuid) -> Result<Option<NutritionData>> {
        let res = sqlx::query!(
            r#"SELECT energy, protein, carbohydrates, sugar, fat, saturated_fat, salt FROM food_nutrition_data WHERE food_id = $1"#,
            food_id
        ).fetch_optional(&self.pool)
        .await?;
        let result = match res {
            Some(res) => Some(NutritionData {
                energy: u32::try_from(res.energy)?,
                protein: u32::try_from(res.protein)?,
                carbohydrates: u32::try_from(res.carbohydrates)?,
                sugar: u32::try_from(res.sugar)?,
                fat: u32::try_from(res.fat)?,
                saturated_fat: u32::try_from(res.saturated_fat)?,
                salt: u32::try_from(res.salt)?,
            }),
            None => None,
        };
        Ok(result)
    }

    async fn get_environment_information(&self, food_id: Uuid) -> Result<Option<EnvironmentInfo>> {
        let res = sqlx::query!(
            r#"SELECT co2_rating, co2_value, water_rating, water_value, animal_welfare_rating, rainforest_rating, max_rating FROM food_env_score WHERE food_id = $1"#,
            food_id
        ).fetch_optional(&self.pool).await?;
        if let Some(res) = res {
            let co2_rating = u32::try_from(res.co2_rating)?;
            let water_rating = u32::try_from(res.water_rating)?;
            let animal_welfare_rating = u32::try_from(res.animal_welfare_rating)?;
            let rainforest_rating = u32::try_from(res.rainforest_rating)?;
            let average_rating =
                (co2_rating + water_rating + animal_welfare_rating + rainforest_rating) / 4;
            Ok(Some(EnvironmentInfo {
                average_rating,
                co2_rating,
                co2_value: u32::try_from(res.co2_value)?,
                water_rating,
                water_value: u32::try_from(res.water_value)?,
                animal_welfare_rating,
                rainforest_rating,
                max_rating: u32::try_from(res.max_rating)?,
            }))
        } else {
            Ok(None)
        }
    }
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use super::*;
    use chrono::Duration;
    use futures::future;
    use sqlx::PgPool;

    const WRONG_UUID: Uuid = Uuid::from_u128(7u128);
    const MAX_WEEKS_DATA: u32 = 5;

    #[sqlx::test(fixtures("canteen"))]
    async fn test_get_canteen(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

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
        assert_eq!(canteens[0].name, "my favorite canteen");
        assert_eq!(canteens[1].name, "second canteen");
        assert_eq!(canteens[2].name, "bad canteen");
        assert!(request.get_canteen(WRONG_UUID).await.unwrap().is_none());
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_get_canteens(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

        let canteen = request.get_canteens().await.unwrap();
        assert!(canteen.len() == 3);
        assert_eq!(canteen[0].name, "my favorite canteen");
        assert_eq!(canteen[1].name, "second canteen");
        assert_eq!(canteen[2].name, "bad canteen");
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_get_line(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

        let lines = request
            .get_lines(Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap())
            .await
            .unwrap();
        assert!(lines.len() == 3);
        assert_eq!(lines[0].name, "line 1");
        assert_eq!(lines[1].name, "line 2");
        assert_eq!(lines[2].name, "special line");
        assert!(request.get_line(WRONG_UUID).await.unwrap().is_none());
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_get_lines(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

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
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

        let meal_id_strs = [
            "f7337122-b018-48ad-b420-6202dc3cb4ff",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
        ];
        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();
        let date = Local::now().date_naive();
        let mut meals = Vec::new();
        for meal_id_str in meal_id_strs {
            let meal_id = Uuid::parse_str(meal_id_str).unwrap();
            if let Ok(Some(meal)) = request.get_meal(meal_id, line_id, date).await {
                meals.push(meal);
            }
        }
        assert_eq!(meals, provide_dummy_meals());

        let meal_id: uuid::Uuid = Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        assert!(request
            .get_meal(WRONG_UUID, line_id, date)
            .await
            .unwrap()
            .is_none());
        assert!(request
            .get_meal(meal_id, WRONG_UUID, date)
            .await
            .unwrap()
            .is_none());
        assert!(request
            .get_meal(meal_id, line_id, Date::default())
            .await
            .unwrap()
            .is_none());
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_get_meals(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);

        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();

        let meals = request
            .get_meals(line_id, Local::now().date_naive())
            .await
            .unwrap();
        assert!(meals.is_some(), "data should ba available");
        let meals = meals.unwrap();
        assert_eq!(meals, provide_dummy_meals());

        let meals_in_future = request
            .get_meals(
                line_id,
                Local::now().date_naive() + Duration::weeks(i64::from(MAX_WEEKS_DATA)),
            )
            .await
            .unwrap();
        assert!(meals_in_future.is_none());

        let meals_in_near_future = request
            .get_meals(
                line_id,
                Local::now().date_naive() + Duration::weeks(i64::from(MAX_WEEKS_DATA) - 1),
            )
            .await
            .unwrap();
        assert!(meals_in_near_future.is_some());

        let meals_in_past = request
            .get_meals(line_id, Local::now().date_naive() - Duration::days(1))
            .await
            .unwrap();
        assert!(meals_in_past.is_none());
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_get_sides(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let date = Local::now().date_naive();
        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();

        let sides = request.get_sides(line_id, date).await.unwrap();
        assert_eq!(sides, provide_dummy_sides());
        assert_eq!(request.get_sides(WRONG_UUID, date).await.unwrap(), vec![]);
        assert_eq!(
            request.get_sides(line_id, Date::default()).await.unwrap(),
            vec![]
        );
    }

    #[sqlx::test(fixtures("meal", "image"))]
    async fn test_get_visible_images(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let meal_id = Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let client_id = Uuid::parse_str("c51d2d81-3547-4f07-af58-ed613c6ece67").unwrap();

        let visible_images = request
            .get_visible_images(meal_id, Some(client_id))
            .await
            .unwrap();
        assert_eq!(visible_images, provide_dummy_images());

        assert_eq!(
            request
                .get_visible_images(WRONG_UUID, Some(client_id))
                .await
                .unwrap(),
            vec![]
        );
    }

    fn provide_dummy_images() -> Vec<Image> {
        let image1 = Image {
            id: Uuid::parse_str("1aa73d5d-1701-4975-aa3c-1422a8bc10e8").unwrap(),
            approved: true,
            rank: 0.5,
            downvotes: 0,
            upvotes: 0,
            upload_date: Local::now().date_naive(),
            report_count: 0,
            meal_id: Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap(),
        };
        let image2 = Image {
            id: Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap(),
            approved: false,
            ..image1
        };
        vec![image1, image2]
    }

    #[sqlx::test(fixtures("meal", "image", "rating"))]
    async fn test_get_personal_rating(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let meal_id = Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let client_id = Uuid::parse_str("c51d2d81-3547-4f07-af58-ed613c6ece67").unwrap();

        let personal_rating = request
            .get_personal_rating(meal_id, client_id)
            .await
            .unwrap();
        assert_eq!(personal_rating, Some(5));
        let personal_rating = request
            .get_personal_rating(WRONG_UUID, client_id)
            .await
            .unwrap();
        assert_eq!(personal_rating, None);
    }

    #[sqlx::test(fixtures("meal", "image", "rating"))]
    async fn test_get_personal_upvote(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let client_id = Uuid::parse_str("c51d2d81-3547-4f07-af58-ed613c6ece67").unwrap();

        let personal_rating = request
            .get_personal_upvote(image_id, client_id)
            .await
            .unwrap();
        assert!(personal_rating);
        let personal_rating = request
            .get_personal_upvote(WRONG_UUID, client_id)
            .await
            .unwrap();
        assert!(!personal_rating);
        let personal_rating = request
            .get_personal_upvote(image_id, WRONG_UUID)
            .await
            .unwrap();
        assert!(!personal_rating);
    }

    #[sqlx::test(fixtures("meal", "image", "rating"))]
    async fn test_get_personal_downvote(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let image_id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let client_id = Uuid::parse_str("00adb927-8cb9-4d80-ae01-d8f2e8f2d4cf").unwrap();

        let personal_rating = request
            .get_personal_downvote(image_id, client_id)
            .await
            .unwrap();
        assert!(personal_rating);
        let personal_rating = request
            .get_personal_downvote(WRONG_UUID, client_id)
            .await
            .unwrap();
        assert!(!personal_rating);
        let personal_rating = request
            .get_personal_downvote(image_id, WRONG_UUID)
            .await
            .unwrap();
        assert!(!personal_rating);
    }

    #[sqlx::test(fixtures("meal", "additive"))]
    async fn test_get_additives(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let food_ids = [
            "f7337122-b018-48ad-b420-6202dc3cb4ff",
            "73cf367b-a536-4b49-ad0c-cb984caa9a08",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
            "0a850476-eda4-4fd8-9f93-579eb85b8c25",
            "1b5633c2-05c5-4444-90e5-2e475bae6463",
        ];
        let food_ids: Vec<Uuid> = food_ids
            .into_iter()
            .filter_map(|id| Uuid::parse_str(id).ok())
            .collect();
        assert_eq!(food_ids.len(), 5);
        let mut additives = Vec::new();
        for food_id in food_ids {
            additives.push(request.get_additives(food_id).await.unwrap());
        }
        assert_eq!(additives, provide_dummy_additives());
    }

    fn provide_dummy_additives() -> Vec<Vec<Additive>> {
        vec![
            vec![],
            vec![],
            vec![],
            vec![],
            vec![Additive::PreservingAgents, Additive::AntioxidantAgents],
        ]
    }

    #[sqlx::test(fixtures("meal", "allergen"))]
    async fn test_get_allergens(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let food_ids = [
            "f7337122-b018-48ad-b420-6202dc3cb4ff",
            "73cf367b-a536-4b49-ad0c-cb984caa9a08",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
            "0a850476-eda4-4fd8-9f93-579eb85b8c25",
            "1b5633c2-05c5-4444-90e5-2e475bae6463",
        ];
        let food_ids: Vec<Uuid> = food_ids
            .into_iter()
            .filter_map(|id| Uuid::parse_str(id).ok())
            .collect();
        assert_eq!(food_ids.len(), 5);
        let mut allergens = Vec::new();
        for food_id in food_ids {
            allergens.push(request.get_allergens(food_id).await.unwrap());
        }
        assert_eq!(allergens, provide_dummy_allergens());
    }

    fn provide_dummy_allergens() -> Vec<Vec<Allergen>> {
        vec![
            vec![Allergen::We],
            vec![],
            vec![Allergen::Ei, Allergen::ML, Allergen::We],
            vec![Allergen::Se, Allergen::So, Allergen::We],
            vec![Allergen::ML, Allergen::Se, Allergen::So],
        ]
    }

    #[sqlx::test(fixtures("meal", "environment_info"))]
    async fn test_get_environment_info(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let food_ids = [
            "f7337122-b018-48ad-b420-6202dc3cb4ff",
            "73cf367b-a536-4b49-ad0c-cb984caa9a08",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
            "0a850476-eda4-4fd8-9f93-579eb85b8c25",
        ];
        let food_ids: Vec<Uuid> = food_ids
            .into_iter()
            .filter_map(|id| Uuid::parse_str(id).ok())
            .collect();
        assert_eq!(food_ids.len(), 4);
        let mut environment_infos = Vec::new();
        for food_id in food_ids {
            environment_infos.push(request.get_environment_information(food_id).await.unwrap());
        }
        assert_eq!(environment_infos, provide_dummy_environment_infos());
    }

    fn provide_dummy_environment_infos() -> Vec<Option<EnvironmentInfo>> {
        vec![
            Some(EnvironmentInfo {
                average_rating: 2,
                co2_rating: 2,
                co2_value: 200,
                water_rating: 3,
                water_value: 10,
                animal_welfare_rating: 1,
                rainforest_rating: 2,
                max_rating: 3,
            }),
            None,
            Some(EnvironmentInfo {
                average_rating: 3,
                co2_rating: 1,
                co2_value: 2,
                water_rating: 3,
                water_value: 4,
                animal_welfare_rating: 5,
                rainforest_rating: 6,
                max_rating: 7,
            }),
            Some(EnvironmentInfo {
                average_rating: 1,
                co2_rating: 1,
                co2_value: 1,
                water_rating: 1,
                water_value: 1,
                animal_welfare_rating: 1,
                rainforest_rating: 1,
                max_rating: 1,
            }),
        ]
    }

    #[sqlx::test(fixtures("meal", "nutrition_data"))]
    async fn test_get_nutrition_data(pool: PgPool) {
        let request = PersistentRequestData::new(pool, MAX_WEEKS_DATA);
        let food_ids = [
            "f7337122-b018-48ad-b420-6202dc3cb4ff",
            "73cf367b-a536-4b49-ad0c-cb984caa9a08",
            "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
            "0a850476-eda4-4fd8-9f93-579eb85b8c25",
        ];
        let food_ids: Vec<Uuid> = food_ids
            .into_iter()
            .filter_map(|id| Uuid::parse_str(id).ok())
            .collect();
        assert_eq!(food_ids.len(), 4);
        let mut nutrition_data = Vec::new();
        for food_id in food_ids {
            nutrition_data.push(request.get_nutrition_data(food_id).await.unwrap());
        }
        assert_eq!(nutrition_data, provide_dummy_nutrition_data());
    }

    fn provide_dummy_nutrition_data() -> Vec<Option<NutritionData>> {
        vec![
            Some(NutritionData {
                energy: 2,
                protein: 200,
                carbohydrates: 3,
                sugar: 10,
                fat: 1,
                saturated_fat: 2,
                salt: 3,
            }),
            None,
            Some(NutritionData {
                energy: 1,
                protein: 2,
                carbohydrates: 3,
                sugar: 4,
                fat: 5,
                saturated_fat: 6,
                salt: 7,
            }),
            Some(NutritionData {
                energy: 1,
                protein: 1,
                carbohydrates: 1,
                sugar: 1,
                fat: 1,
                saturated_fat: 1,
                salt: 1,
            }),
        ]
    }

    fn provide_dummy_sides() -> Vec<Side> {
        vec![Side {
            id: Uuid::parse_str("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap(),
            name: "zu jedem Gericht reichen wir ein Dessert oder Salat".to_string(),
            food_type: FoodType::Unknown,
            price: Price {
                price_student: 0,
                price_employee: 0,
                price_guest: 0,
                price_pupil: 0,
            },
        }]
    }

    fn provide_dummy_meals() -> Vec<Meal> {
        let meal1 = Meal {
            id: Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap(),
            name: "2 Dampfnudeln mit Vanillesoße".to_string(),
            food_type: FoodType::Vegetarian,
            price: Price {
                price_student: 320,
                price_employee: 420,
                price_guest: 460,
                price_pupil: 355,
            },
            last_served: None,
            next_served: None,
            frequency: 0,
            new: true,
            rating_count: 0,
            average_rating: 0.0,
            date: Local::now().date_naive(),
            line_id: Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(),
        };
        let meal2 = Meal {
            id: Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap(),
            name: "Geflügel - Cevapcici, Ajvar, Djuvec Reis".to_string(),
            food_type: FoodType::Unknown,
            ..meal1
        };
        vec![meal2, meal1]
    }
}
