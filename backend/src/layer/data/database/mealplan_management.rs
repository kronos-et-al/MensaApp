//! Module responsible for handling database requests for meal plan management operations.
use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::{
        mensa_parser::model::ParseEnvironmentInfo,
        persistent_data::{MealplanManagementDataAccess, Result},
    },
    util::{Additive, Allergen, Date, FoodType, NutritionData, Price, Uuid},
};

/// Class for performing database operations necessary for meal plan management.
#[derive(Debug)]
pub struct PersistentMealplanManagementData {
    pub(super) pool: Pool<Postgres>,
}

const THRESHOLD_MEAL: f32 = 0.785;
const THRESHOLD_LINE: f32 = 0.894;
const THRESHOLD_CANTEEN: f32 = 0.8515;

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl MealplanManagementDataAccess for PersistentMealplanManagementData {
    async fn dissolve_relations(&self, canteen_id: Uuid, date: Date) -> Result<()> {
        sqlx::query!(
            "
            DELETE FROM food_plan
            WHERE serve_date = $1
            AND line_id IN (SELECT line_id FROM line WHERE canteen_id = $2)
            ",
            date,
            canteen_id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            "SELECT canteen_id FROM canteen WHERE similarity(name, $1) >= $2 ORDER BY similarity(name, $1) DESC",
            similar_name, THRESHOLD_CANTEEN
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_line(&self, similar_name: &str, canteen_id: Uuid) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            "SELECT line_id FROM line WHERE similarity(name, $1) >= $3 AND canteen_id = $2 ORDER BY similarity(name, $1) DESC",
            similar_name, canteen_id, THRESHOLD_LINE
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_meal(
        &self,
        similar_name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            // the `<@` operator checks whether each element in the left array is also present in the right
            r#"
            SELECT food_id 
            FROM food JOIN meal USING (food_id)
            WHERE similarity(name, $1) >= $4 AND food_type = $2
            AND food_id IN (
                -- all food_id's with same allergens
                SELECT food_id 
                FROM food_allergen FULL JOIN food USING (food_id)
                GROUP BY food_id 
				HAVING COALESCE(array_agg(allergen) FILTER (WHERE allergen IS NOT NULL), ARRAY[]::allergen[]) <@ $3::allergen[]
				AND COALESCE(array_agg(allergen) FILTER (WHERE allergen IS NOT NULL), ARRAY[]::allergen[]) @> $3::allergen[]
            )
            ORDER BY similarity(name, $1) DESC
            "#,
            similar_name,
            food_type as _,
            allergens
                .iter()
                .copied()
                .map(Allergen::to_db_string)
                .collect::<Vec<_>>() as _,
            THRESHOLD_MEAL
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_side(
        &self,
        similar_name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            // the `<@` operator checks whether each element in the left array is also present in the right
            r#"
            SELECT food_id 
            FROM food
            WHERE similarity(name, $1) >= $4 AND food_type = $2 AND food_id NOT IN (SELECT food_id FROM meal)
            AND food_id IN (
                -- all food_id's with same allergens
                SELECT food_id 
                FROM food_allergen FULL JOIN food USING (food_id)
                GROUP BY food_id 
				HAVING COALESCE(array_agg(allergen) FILTER (WHERE allergen IS NOT NULL), ARRAY[]::allergen[]) <@ $3::allergen[]
				AND COALESCE(array_agg(allergen) FILTER (WHERE allergen IS NOT NULL), ARRAY[]::allergen[]) @> $3::allergen[]
            )
            ORDER BY similarity(name, $1) DESC
            "#,
            similar_name,
            food_type as _,
            allergens
                .iter()
                .copied()
                .map(Allergen::to_db_string)
                .collect::<Vec<_>>() as _,
            THRESHOLD_MEAL
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_canteen(&self, uuid: Uuid, name: &str, position: u32) -> Result<()> {
        sqlx::query!(
            "
            UPDATE canteen
            SET name = $2, position = $3
            WHERE canteen_id = $1
            ",
            uuid,
            name,
            i32::try_from(position)?
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn update_line(&self, uuid: Uuid, name: &str, position: u32) -> Result<()> {
        sqlx::query!(
            "
            UPDATE line
            SET name = $2, position = $3
            WHERE line_id = $1
            ",
            uuid,
            name,
            i32::try_from(position)?
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }

    async fn update_meal(&self, uuid: Uuid, name: &str) -> Result<()> {
        self.update_food(uuid, name).await
    }

    async fn update_side(&self, uuid: Uuid, name: &str) -> Result<()> {
        self.update_food(uuid, name).await
    }

    async fn insert_canteen(&self, name: &str, position: u32) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            INSERT INTO canteen (name, position)
            VALUES ($1, $2)
            RETURNING canteen_id
            ",
            name,
            i32::try_from(position)?
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn insert_line(&self, canteen_id: Uuid, name: &str, position: u32) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            INSERT INTO line (canteen_id, name, position)
            VALUES ($1, $2, $3)
            RETURNING line_id
            ",
            canteen_id,
            name,
            i32::try_from(position)?
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn insert_meal(
        &self,
        name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid> {
        self.insert_food(
            name,
            food_type,
            allergens,
            additives,
            nutrition_data,
            environment_information,
            true,
        )
        .await
    }

    async fn insert_side(
        &self,
        name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid> {
        self.insert_food(
            name,
            food_type,
            allergens,
            additives,
            nutrition_data,
            environment_information,
            false,
        )
        .await
    }

    async fn add_meal_to_plan(
        &self,
        meal_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        self.add_to_plan(meal_id, line_id, date, price).await
    }

    async fn add_side_to_plan(
        &self,
        side_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        self.add_to_plan(side_id, line_id, date, price).await
    }
}

impl PersistentMealplanManagementData {
    async fn update_food(&self, food_id: Uuid, food_name: &str) -> Result<()> {
        sqlx::query!(
            "UPDATE food SET name = $2 WHERE food_id = $1",
            food_id,
            food_name
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn add_to_plan(
        &self,
        food_id: Uuid,
        line_id: Uuid,
        date: Date,
        price: Price,
    ) -> Result<()> {
        sqlx::query!(
            "
            INSERT INTO food_plan (line_id, food_id, serve_date, 
                price_student, price_employee, price_guest, price_pupil) 
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ",
            line_id,
            food_id,
            date,
            i32::try_from(price.price_student)? as _,
            i32::try_from(price.price_employee)? as _,
            i32::try_from(price.price_guest)? as _,
            i32::try_from(price.price_pupil)? as _,
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }
    #[allow(clippy::too_many_arguments)]
    async fn insert_food(
        &self,
        name: &str,
        food_type: FoodType,
        allergens: &[Allergen],
        additives: &[Additive],
        nutrition_data: Option<NutritionData>,
        environment_information: Option<ParseEnvironmentInfo>,
        is_meal: bool,
    ) -> Result<Uuid> {
        let food_id = sqlx::query_scalar!(
            r#"INSERT INTO food(name, food_type) VALUES ($1, $2) RETURNING food_id"#,
            name,
            food_type as _
        )
        .fetch_one(&self.pool)
        .await?;

        if is_meal {
            sqlx::query!("INSERT INTO meal(food_id) VALUES ($1)", food_id)
                .execute(&self.pool)
                .await?;
        }

        let allergens: Vec<String> = allergens
            .iter()
            .copied()
            .map(Allergen::to_db_string)
            .collect();

        sqlx::query!(
            "INSERT INTO food_allergen(food_id, allergen) VALUES ($1, UNNEST($2::allergen[]))",
            food_id,
            allergens as _
        )
        .execute(&self.pool)
        .await?;

        let additives: Vec<String> = additives
            .iter()
            .copied()
            .map(Additive::to_db_string)
            .collect();

        sqlx::query!(
            "INSERT INTO food_additive(food_id, additive) VALUES ($1, UNNEST($2::additive[]))",
            food_id,
            additives as _
        )
        .execute(&self.pool)
        .await?;

        if let Some(nutrition_data) = nutrition_data {
            sqlx::query!(
                "INSERT INTO food_nutrition_data(energy, protein, carbohydrates, sugar, fat, saturated_fat, salt, food_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", 
                i32::try_from(nutrition_data.energy)? as _,
                i32::try_from(nutrition_data.protein)? as _,
                i32::try_from(nutrition_data.carbohydrates)? as _,
                i32::try_from(nutrition_data.sugar)? as _,
                i32::try_from(nutrition_data.fat)? as _,
                i32::try_from(nutrition_data.saturated_fat)? as _,
                i32::try_from(nutrition_data.salt)? as _,
                food_id,
            ).execute(&self.pool).await?;
        }

        if let Some(environment_information) = environment_information {
            sqlx::query!(
                "INSERT INTO food_env_score(co2_rating, co2_value, water_rating, water_value, animal_welfare_rating, rainforest_rating, max_rating, food_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)", 
                i32::try_from(environment_information.co2_rating)? as _,
                i32::try_from(environment_information.co2_value)? as _,
                i32::try_from(environment_information.water_rating)? as _,
                i32::try_from(environment_information.water_value)? as _,
                i32::try_from(environment_information.animal_welfare_rating)? as _,
                i32::try_from(environment_information.rainforest_rating)? as _,
                i32::try_from(environment_information.max_rating)? as _,
                food_id,
            ).execute(&self.pool).await?;
        }

        Ok(food_id)
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    #![allow(clippy::cast_sign_loss)]

    use super::*;
    use crate::util::Additive::Sulphur;
    use crate::util::Allergen::{Ei, Se, So, We, ML};
    use crate::util::Date;
    use chrono::Local;
    use sqlx::PgPool;
    use std::collections::HashMap;
    use std::str::FromStr;

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_dissolve_relations(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let canteen_id = Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap();
        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();
        let date = Date::from_str("2023-07-10").unwrap();

        let res = req.dissolve_relations(canteen_id, date).await;
        assert!(res.is_ok());

        let deleted = sqlx::query!(
            r#"SELECT * FROM food_plan WHERE line_id = $1 AND serve_date = $2"#,
            line_id,
            date
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert!(deleted.is_empty());
    }

    #[sqlx::test(fixtures("similar_canteen"))]
    async fn test_get_similar_canteen(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let tests = [
            // Identical
            (
                Uuid::parse_str("8f10c56d-da9b-4f62-b4c1-16feb0f98c67").unwrap(),
                "Mensa am Adenauerring",
                true,
            ),
            (
                Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap(),
                "chicco di caffe Karlsruhe",
                true,
            ),
            (
                Uuid::parse_str("f2885f67-fc95-4205-bc7d-b2fb78cee0a8").unwrap(),
                "Cafebar Moltke",
                true,
            ),
            // 'Similar'
            (
                Uuid::parse_str("8f10c56d-da9b-4f62-b4c1-16feb0f98c67").unwrap(),
                "   Mensa   am   Adenauerring  ",
                true,
            ),
            (
                Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap(),
                "chicco di caffé Karlsruhe",
                true,
            ),
            (
                Uuid::parse_str("f2885f67-fc95-4205-bc7d-b2fb78cee0a8").unwrap(),
                "Cafebar Moltke 2",
                true,
            ),
            // No longer 'similar'
            (Uuid::default(), "Adenauerring", false),
            (Uuid::default(), "chicco di caffe", false),
            (Uuid::default(), "Moltkestraße", false),
        ];

        for (uuid, name, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            req.get_similar_canteen(name).await.unwrap().map_or_else(
                || {
                    println!("{is_similar}");
                    assert!(!is_similar);
                },
                |res| {
                    println!("{res}");
                    assert_eq!(uuid, res);
                },
            );
        }
    }

    #[sqlx::test(fixtures("canteen", "similar_line"))]
    async fn test_get_similar_line(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool };
        let canteen_id = Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap();
        let tests = [
            // Identical
            (
                Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap(),
                "LINIE 1 GUT & GÜNSTIG",
                true,
            ),
            (
                Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(),
                "LINIE 2 VEGANE LINIE",
                true,
            ),
            (
                Uuid::parse_str("a4956171-a5fc-4c6b-a028-3cb2e5d2bedb").unwrap(),
                "LINIE 4",
                true,
            ),
            // 'Similar'
            (
                Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap(),
                "LINIE GUT & GÜNSTIG",
                true,
            ),
            (
                Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap(),
                "LINIE 2: VEGANE LINIE",
                true,
            ),
            (
                Uuid::parse_str("a4956171-a5fc-4c6b-a028-3cb2e5d2bedb").unwrap(),
                "Linie 4",
                true,
            ),
            // No longer 'similar'
            (Uuid::default(), "GUT & GÜNSTIG", false),
            (Uuid::default(), "LINIE 2", false),
            (Uuid::default(), "LINIE 3", false),
        ];

        for (uuid, name, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            req.get_similar_line(name, canteen_id)
                .await
                .unwrap()
                .map_or_else(
                    || {
                        println!("{is_similar}");
                        assert!(!is_similar);
                    },
                    |res| {
                        println!("{res}");
                        assert_eq!(uuid, res);
                    },
                );
        }
    }

    #[sqlx::test(fixtures("similar_meal", "allergen", "additive"))]
    async fn test_get_similar_meal(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool };

        let addons: HashMap<&str, (Vec<Additive>, Vec<Allergen>)> = HashMap::from([
            ("f7337122-b018-48ad-b420-6202dc3cb4ff", (vec![], vec![We])),
            (
                "25cb8c50-75a4-48a2-b4cf-8ab2566d8bec",
                (vec![Sulphur], vec![Ei, ML, We]),
            ),
            (
                "0a850476-eda4-4fd8-9f93-579eb85b8c25",
                (vec![], vec![Se, So, We]),
            ),
            ("00000000-0000-0000-0000-000000000000", (vec![], vec![])),
        ]);

        let tests = [
            // Identical
            (
                Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap(),
                "Geflügel - Cevapcici, Ajvar, Djuvec Reis",
                FoodType::Unknown,
                true,
            ),
            (
                Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap(),
                "2 Dampfnudeln mit Vanillesoße",
                FoodType::Vegetarian,
                true,
            ),
            (
                Uuid::parse_str("0a850476-eda4-4fd8-9f93-579eb85b8c25").unwrap(),
                "Mediterraner Gemüsegulasch mit Räuchertofu, dazu Sommerweizen",
                FoodType::Vegan,
                true,
            ),
            // 'Similar' with identical addons
            (
                Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap(),
                "Geflügel - Cevapcici, Ajvar, Reis",
                FoodType::Unknown,
                true,
            ),
            (
                Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap(),
                "Dampfnudeln mit Vanillesoße",
                FoodType::Vegetarian,
                true,
            ),
            (
                Uuid::parse_str("0a850476-eda4-4fd8-9f93-579eb85b8c25").unwrap(),
                "Mediterraner Gemüsegulasch mit Räuchertofu und Sommerweizen",
                FoodType::Vegan,
                true,
            ),
            // No longer 'similar' with identical addons
            (
                Uuid::default(),
                "Geflügel - Cevapcici",
                FoodType::Unknown,
                false,
            ),
            (Uuid::default(), "Dampfnudeln", FoodType::Vegetarian, false),
            (Uuid::default(), "", FoodType::Vegan, false),
        ];

        for (uuid, name, food_type, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            let (additives, allergens) = addons.get(&*uuid.to_string()).unwrap();
            req.get_similar_meal(name, food_type, allergens, additives)
                .await
                .unwrap()
                .map_or_else(
                    || {
                        println!("{is_similar}");
                        assert!(!is_similar);
                    },
                    |res| {
                        println!("{res}");
                        assert_eq!(uuid, res);
                    },
                );
        }
    }

    #[sqlx::test(fixtures("similar_meal", "allergen", "additive"))]
    async fn test_get_similar_side(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool };

        let addons: HashMap<&str, (Vec<Additive>, Vec<Allergen>)> = HashMap::from([
            ("73cf367b-a536-4b49-ad0c-cb984caa9a08", (vec![], vec![])),
            ("836b17fb-cb16-425d-8d3c-c274a9cdbd0c", (vec![], vec![])),
            ("2c662143-eb84-4142-aa98-bd7bdf84c498", (vec![], vec![])),
            ("00000000-0000-0000-0000-000000000000", (vec![], vec![])),
        ]);

        let tests = [
            // Identical
            (
                Uuid::parse_str("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap(),
                "zu jedem Gericht reichen wir ein Dessert oder Salat",
                FoodType::Unknown,
                true,
            ),
            (
                Uuid::parse_str("836b17fb-cb16-425d-8d3c-c274a9cdbd0c").unwrap(),
                "Salatbuffet mit frischer Rohkost, Blattsalate und hausgemachten Dressings, Preis je 100 g",
                FoodType::Vegan,
                true,
            ),
            (
                Uuid::parse_str("2c662143-eb84-4142-aa98-bd7bdf84c498").unwrap(),
                "Insalata piccola - kleiner Blattsalat mit Thunfisch und Paprika",
                FoodType::Unknown,
                true,
            ),
            // 'Similar' with identical addons
            (
                Uuid::parse_str("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap(),
                "zu jedem Gericht reichen wir Desserts oder Salate",
                FoodType::Unknown,
                true,
            ),
            (
                Uuid::parse_str("836b17fb-cb16-425d-8d3c-c274a9cdbd0c").unwrap(),
                "Salatbuffet mit frischer Rohkost, Blattsalate und hausgemachten Dressings",
                FoodType::Vegan,
                true,
            ),
            (
                Uuid::parse_str("2c662143-eb84-4142-aa98-bd7bdf84c498").unwrap(),
                "Insalata piccola - Blattsalat mit Thunfisch und Paprika",
                FoodType::Unknown,
                true,
            ),
            // No longer 'similar' with identical addons
            (Uuid::default(), "zu jedem Gericht reichen wir ein Dessert", FoodType::Unknown, false),
            (Uuid::default(), "Salatbuffet mit frischer Rohkost", FoodType::Vegan, false),
            (Uuid::default(), "Insalata piccola", FoodType::Unknown, false),
        ];

        for (uuid, name, food_type, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            let (additives, allergens) = addons.get(&*uuid.to_string()).unwrap();
            req.get_similar_side(name, food_type, allergens, additives)
                .await
                .unwrap()
                .map_or_else(
                    || {
                        println!("{is_similar}");
                        assert!(!is_similar);
                    },
                    |res| {
                        println!("{res}");
                        assert_eq!(uuid, res);
                    },
                );
        }
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_add_to_plan(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };
        let food_id = Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap();
        let line_id = Uuid::parse_str("119c55b7-e539-4849-bad1-984efff2aad6").unwrap();
        let date = Local::now().date_naive();
        let price = Price {
            price_student: 42,
            price_employee: 420,
            price_guest: 4200,
            price_pupil: 42000,
        };
        let res = req.add_to_plan(food_id, line_id, date, price).await;
        assert!(res.is_ok());

        let selections = sqlx::query!(
            r#"SELECT * FROM food_plan WHERE line_id = $1 AND food_id = $2 AND serve_date = $3"#,
            line_id,
            food_id,
            date
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.line_id, line_id);
        assert_eq!(selection.food_id, food_id);
        assert_eq!(selection.serve_date, date);
        assert_eq!(selection.price_student as u32, price.price_student);
        assert_eq!(selection.price_employee as u32, price.price_employee);
        assert_eq!(selection.price_guest as u32, price.price_guest);
        assert_eq!(selection.price_pupil as u32, price.price_pupil);
    }

    #[sqlx::test(fixtures("meal", "allergen", "additive"))]
    async fn test_insert_food(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let food_type = FoodType::Vegan;
        let name = "TEST_FOOD";
        let additives = vec![Additive::Alcohol];
        let allergens = vec![Allergen::Ca, Allergen::Pa];
        let nutrition_data = Some(NutritionData {
            energy: 1,
            protein: 2,
            carbohydrates: 3,
            sugar: 4,
            fat: 5,
            saturated_fat: 6,
            salt: 7,
        });
        let environment_info = Some(ParseEnvironmentInfo {
            co2_rating: 1,
            co2_value: 2,
            water_rating: 3,
            water_value: 4,
            animal_welfare_rating: 5,
            rainforest_rating: 6,
            max_rating: 7,
        });

        let res = req
            .insert_food(
                name,
                food_type,
                &allergens,
                &additives,
                nutrition_data,
                environment_info,
                true,
            )
            .await;
        //assert!(res.is_ok());
        let food_id = res.unwrap();

        let db_additives = sqlx::query_scalar!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(db_additives, additives);

        let db_allergens = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(db_allergens, allergens);

        let selections = sqlx::query!(
            r#"SELECT name, food_type as "food_type: FoodType" FROM food WHERE food_id = $1"#,
            food_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.food_type, food_type);
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_insert_canteen(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let name = "TEST_CANTEEN";
        let pos = 42_u32;

        let res = req.insert_canteen(name, pos).await;
        assert!(res.is_ok());
        let canteen_id = res.unwrap();

        let selections = sqlx::query!(
            r#"SELECT name, position FROM canteen WHERE canteen_id = $1"#,
            canteen_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.position as u32, pos);
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_insert_line(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let canteen_id = Uuid::parse_str("f2885f67-fc95-4205-bc7d-b2fb78cee0a8").unwrap();
        let name = "TEST_LINE";
        let pos = 42_u32;

        let res = req.insert_line(canteen_id, name, pos).await;
        assert!(res.is_ok());
        let line_id = res.unwrap();

        let selections = sqlx::query!(
            r#"SELECT name, position FROM line WHERE line_id = $1"#,
            line_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.position as u32, pos);
    }

    #[sqlx::test(fixtures("meal", "allergen", "additive"))]
    async fn test_update_food(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let food_id = Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let name = "TEST_FOOD";

        let res = req.update_food(food_id, name).await;
        assert!(res.is_ok());

        let selections = sqlx::query!(r#"SELECT name FROM food WHERE food_id = $1"#, food_id)
            .fetch_all(&pool)
            .await
            .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_update_canteen(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let canteen_id = Uuid::parse_str("8f10c56d-da9b-4f62-b4c1-16feb0f98c67").unwrap();
        let name = "TEST_CANTEEN";
        let pos = 42_u32;

        let res = req.update_canteen(canteen_id, name, pos).await;
        assert!(res.is_ok());

        let selections = sqlx::query!(
            r#"SELECT name, position FROM canteen WHERE canteen_id = $1"#,
            canteen_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.position as u32, pos);
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_update_line(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let line_id = Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap();
        let name = "TEST_LINE";
        let pos = 42_u32;

        let res = req.update_line(line_id, name, pos).await;
        assert!(res.is_ok());

        let selections = sqlx::query!(
            r#"SELECT name, position FROM line WHERE line_id = $1"#,
            line_id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.position as u32, pos);
    }

    #[sqlx::test(fixtures("meal"))]
    async fn test_update_meal(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };

        // test meal updated
        let food_uuid = Uuid::try_from("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let name = "mealy";

        let ok = data.update_meal(food_uuid, name).await.is_ok();
        assert!(ok);

        let actual_name =
            sqlx::query_scalar!("SELECT name FROM food where food_id = $1", food_uuid)
                .fetch_one(&pool)
                .await
                .unwrap();
        assert_eq!(&actual_name, name);
    }

    #[sqlx::test(fixtures("meal"))]
    async fn test_update_side(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };
        let name = "side";

        // test side changed
        let side_uuid = Uuid::try_from("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap();
        let ok = data.update_side(side_uuid, name).await.is_ok();
        assert!(ok);

        let actual_name =
            sqlx::query_scalar!("SELECT name FROM food where food_id = $1", side_uuid)
                .fetch_one(&pool)
                .await
                .unwrap();
        assert_eq!(&actual_name, name);
    }

    #[sqlx::test()]
    async fn test_insert_meal(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };
        let name = "mealy";

        let allergens = &[Allergen::Ca, Allergen::Di];
        let additives = &[Additive::Alcohol];
        let nutrition_data = Some(NutritionData {
            energy: 1,
            protein: 2,
            carbohydrates: 3,
            sugar: 4,
            fat: 5,
            saturated_fat: 6,
            salt: 7,
        });
        let environment_info = Some(ParseEnvironmentInfo {
            co2_rating: 1,
            co2_value: 2,
            water_rating: 3,
            water_value: 4,
            animal_welfare_rating: 5,
            rainforest_rating: 6,
            max_rating: 7,
        });
        let id = data
            .insert_meal(
                name,
                FoodType::Beef,
                allergens,
                additives,
                nutrition_data,
                environment_info,
            )
            .await
            .expect("meal should be successfully inserted");

        let food = sqlx::query!(
            r#"SELECT name, food_type as "food_type: FoodType" FROM food JOIN meal USING (food_id) where food_id = $1"#,
            id
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(&food.name, name);
        assert_eq!(food.food_type, FoodType::Beef);

        let actual_allergens = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(&actual_allergens, allergens);

        let actual_additives = sqlx::query_scalar!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(&actual_additives, additives);
    }

    #[sqlx::test]
    async fn test_insert_side(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };
        let name = "side";

        let allergens = &[Allergen::Ca, Allergen::Di];
        let additives = &[Additive::Alcohol];
        let nutrition_data = Some(NutritionData {
            energy: 1,
            protein: 2,
            carbohydrates: 3,
            sugar: 4,
            fat: 5,
            saturated_fat: 6,
            salt: 7,
        });
        let environment_info = Some(ParseEnvironmentInfo {
            co2_rating: 1,
            co2_value: 2,
            water_rating: 3,
            water_value: 4,
            animal_welfare_rating: 5,
            rainforest_rating: 6,
            max_rating: 7,
        });

        let id = data
            .insert_side(
                name,
                FoodType::Beef,
                allergens,
                additives,
                nutrition_data,
                environment_info,
            )
            .await
            .expect("meal should be successfully inserted");

        let food = sqlx::query!(
            r#"SELECT name, food_type as "food_type: FoodType" FROM food where food_id = $1"#,
            id
        )
        .fetch_one(&pool)
        .await
        .unwrap();
        assert_eq!(&food.name, name);
        assert_eq!(food.food_type, FoodType::Beef);

        // not a main dish => side
        let result = sqlx::query!("SELECT * from meal WHERE food_id = $1", id)
            .fetch_all(&pool)
            .await
            .unwrap();
        assert!(result.is_empty());

        let actual_allergens = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(&actual_allergens, allergens);

        let actual_additives = sqlx::query_scalar!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            id
        )
        .fetch_all(&pool)
        .await
        .unwrap();
        assert_eq!(&actual_additives, additives);
    }

    #[sqlx::test(fixtures("canteen", "line", "meal"))]
    async fn test_add_meal_to_plan(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };

        let meal_id = Uuid::try_from("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap();
        let line_id = Uuid::try_from("61b27158-817c-4716-bd41-2a8901391ea4").unwrap();
        let price = Price {
            price_student: 1,
            price_employee: 2,
            price_guest: 3,
            price_pupil: 4,
        };
        let date = Date::from_ymd_opt(2020, 10, 30).unwrap();
        data.add_meal_to_plan(meal_id, line_id, date, price)
            .await
            .expect("meal should be added to plan");

        let record = sqlx::query!(
            "SELECT * FROM food_plan WHERE food_id = $1 AND line_id = $2",
            meal_id,
            line_id
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        assert_eq!(date, record.serve_date);
        assert_eq!(price.price_student, record.price_student as u32);
        assert_eq!(price.price_employee, record.price_employee as u32);
        assert_eq!(price.price_guest, record.price_guest as u32);
        assert_eq!(price.price_pupil, record.price_pupil as u32);
    }

    #[sqlx::test(fixtures("canteen", "line", "meal"))]
    async fn test_add_side_to_plan(pool: PgPool) {
        let data = PersistentMealplanManagementData { pool: pool.clone() };

        let side_id = Uuid::try_from("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap();
        let line_id = Uuid::try_from("61b27158-817c-4716-bd41-2a8901391ea4").unwrap();
        let price = Price {
            price_student: 1,
            price_employee: 2,
            price_guest: 3,
            price_pupil: 4,
        };
        let date = Date::from_ymd_opt(2020, 10, 30).unwrap();
        data.add_side_to_plan(side_id, line_id, date, price)
            .await
            .expect("meal should be added to plan");

        let record = sqlx::query!(
            "SELECT * FROM food_plan WHERE food_id = $1 AND line_id = $2",
            side_id,
            line_id
        )
        .fetch_one(&pool)
        .await
        .unwrap();

        assert_eq!(date, record.serve_date);
        assert_eq!(price.price_student, record.price_student as u32);
        assert_eq!(price.price_employee, record.price_employee as u32);
        assert_eq!(price.price_guest, record.price_guest as u32);
        assert_eq!(price.price_pupil, record.price_pupil as u32);
    }
}
