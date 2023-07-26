use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use super::types::DatabasePrice;
use crate::{
    interface::persistent_data::{MealplanManagementDataAccess, Result},
    util::{Additive, Allergen, Date, MealType, Price, Uuid},
};

pub struct PersistentMealplanManagementData {
    pub(super) pool: Pool<Postgres>,
}

const THRESHOLD: f32 = 0.8;

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
            "SELECT canteen_id FROM canteen WHERE name % $1 AND similarity(name, $1) >= $2 ORDER BY similarity(name, $1) DESC",
            similar_name, THRESHOLD
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_line(&self, similar_name: &str) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            "SELECT line_id FROM line WHERE name % $1 AND similarity(name, $1) >= $2 ORDER BY similarity(name, $1) DESC",
            similar_name, THRESHOLD
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_meal(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            // the `<@` operator checks whether each element in the left array is also present in the right
            "SELECT food_id 
            FROM food JOIN meal USING (food_id) JOIN food_additive USING (food_id) 
                JOIN food_allergen USING (food_id)
            WHERE name % $1 AND similarity(name, $1) >= $4
            GROUP BY food_id
            HAVING array_agg(allergen) <@ $2::Allergen[] AND array_agg(allergen) @> $2::Allergen[]
                AND array_agg(additive) <@ $3::Additive[] AND array_agg(additive) @> $3::Additive[]
            ORDER BY similarity(name, $1) DESC",
            similar_name,
            allergens
                .iter()
                .copied()
                .map(Allergen::to_db_string)
                .collect::<Vec<_>>() as _,
            additives
                .iter()
                .copied()
                .map(Additive::to_db_string)
                .collect::<Vec<_>>() as _,
            THRESHOLD
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn get_similar_side(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        sqlx::query_scalar!(
            // the `<@` operator checks whether each element in the left array is also present in the right
            "SELECT food_id 
            FROM food JOIN food_additive USING (food_id) 
                JOIN food_allergen USING (food_id)
            WHERE food_id NOT IN (SELECT food_id FROM meal) AND name % $1 AND similarity(name, $1) >= $4
            GROUP BY food_id
            HAVING array_agg(allergen) <@ $2::Allergen[] AND array_agg(allergen) @> $2::Allergen[]
                AND array_agg(additive) <@ $3::Additive[] AND array_agg(additive) @> $3::Additive[]
            ORDER BY similarity(name, $1) DESC",
            similar_name,
            allergens
                .iter()
                .copied()
                .map(Allergen::to_db_string)
                .collect::<Vec<_>>() as _,
            additives
                .iter()
                .copied()
                .map(Additive::to_db_string)
                .collect::<Vec<_>>() as _,
            THRESHOLD
        )
        .fetch_optional(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_canteen(&self, uuid: Uuid, name: &str, position: u32) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            UPDATE canteen
            SET name = $2, position = $3
            WHERE canteen_id = $1
            RETURNING canteen_id
            ",
            uuid,
            name,
            i32::try_from(position)?
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
    }

    async fn update_line(&self, uuid: Uuid, name: &str, position: u32) -> Result<Uuid> {
        sqlx::query_scalar!(
            "
            UPDATE line
            SET name = $2, position = $3
            WHERE line_id = $1
            RETURNING line_id
            ",
            uuid,
            name,
            i32::try_from(position)?
        )
        .fetch_one(&self.pool)
        .await
        .map_err(Into::into)
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
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        self.insert_food(name, meal_type, allergens, additives)
            .await
    }

    async fn insert_side(
        &self,
        name: &str,
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        self.insert_food(name, meal_type, allergens, additives)
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
        let price: DatabasePrice = price.try_into()?;
        sqlx::query!(
            "INSERT INTO food_plan (line_id, food_id, serve_date, price_student, price_employee, price_guest, price_pupil) VALUES ($1, $2, $3, $4, $5, $6, $7)",
            line_id,
            food_id,
            date,
            price.student as _,
            price.employee as _,
            price.guest as _,
            price.pupil as _,
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    async fn insert_food(
        &self,
        name: &str,
        meal_type: MealType,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Uuid> {
        let food_id = sqlx::query_scalar!(
            r#"INSERT INTO food(name, food_type) VALUES ($1, $2) RETURNING food_id"#,
            name,
            meal_type as _
        )
        .fetch_one(&self.pool)
        .await?;

        sqlx::query!("INSERT INTO meal(food_id) VALUES ($1)", food_id)
            .execute(&self.pool)
            .await?;

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

        Ok(food_id)
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]

    use std::collections::HashMap;
    use std::str::FromStr;
    use chrono::{NaiveDate, Utc};
    use super::*;
    use sqlx::PgPool;
    use crate::util::Additive::{AntioxidantAgents, PreservingAgents};
    use crate::util::Allergen::{ML, Se, So, We};

    #[sqlx::test(fixtures("canteen", "line", "food_plan", "meal"))]
    async fn test_dissolve_relations(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let canteen_id = Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap();
        let line_id = Uuid::parse_str("3e8c11fa-906a-4c6a-bc71-28756c6b00ae").unwrap();
        let date = NaiveDate::from_str("2023-07-10").unwrap();

        let res = req.dissolve_relations(canteen_id, date).await;
        assert!(res.is_ok());

        let deleted = sqlx::query!(r#"SELECT * FROM food_plan WHERE line_id = $1 AND serve_date = $2"#, line_id, date).fetch_all(&pool).await.unwrap();
        assert!(deleted.is_empty());
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_get_similar_canteen(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let tests = [
            // Identical
            (Uuid::parse_str("8f10c56d-da9b-4f62-b4c1-16feb0f98c67").unwrap(), "second canteen", true),
            (Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap(), "my favorite canteen", true),
            (Uuid::parse_str("f2885f67-fc95-4205-bc7d-b2fb78cee0a8").unwrap(), "bad canteen", true),

            // 'Similar'
            (Uuid::parse_str("8f10c56d-da9b-4f62-b4c1-16feb0f98c67").unwrap(), "second cantee", true),
            (Uuid::parse_str("10728cc4-1e07-4e18-a9d9-ca45b9782413").unwrap(), "favorite canteen", true),
            (Uuid::parse_str("f2885f67-fc95-4205-bc7d-b2fb78cee0a8").unwrap(), "  bad  canteen ", true),

            // No longer 'similar'
            (Uuid::default(), "second", false),
            (Uuid::default(), "canteen", false),
            (Uuid::default(), "", false),
        ];

        for (uuid, name, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            req.get_similar_canteen(name).await.unwrap().map_or_else(|| {
                    println!("{is_similar}");
                    assert!(!is_similar);
                }, |res| {
                    println!("{res}");
                    assert_eq!(uuid, res);
                });
        }
    }

    #[sqlx::test(fixtures("canteen", "line"))]
    async fn test_get_similar_line(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool };

        let tests = [
            // Identical
            (Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap(), "line 2", true),
            (Uuid::parse_str("119c55b7-e539-4849-bad1-984efff2aad6").unwrap(), "single line", true),
            (Uuid::parse_str("a4956171-a5fc-4c6b-a028-3cb2e5d2bedb").unwrap(), "special line", true),

            // 'Similar'
            //(Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap(), "line2", true), isn't similar
            (Uuid::parse_str("119c55b7-e539-4849-bad1-984efff2aad6").unwrap(), " single   line ", true),
            //(Uuid::parse_str("a4956171-a5fc-4c6b-a028-3cb2e5d2bedb").unwrap(), "specia line", true), isn't similar

            // No longer 'similar'
            (Uuid::default(), "line", false),
            (Uuid::default(), "sing.", false),
            (Uuid::default(), "", false),
        ];

        for (uuid, name, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            req.get_similar_line(name).await.unwrap().map_or_else(|| {
                println!("{is_similar}");
                assert!(!is_similar);
            }, |res| {
                println!("{res}");
                assert_eq!(uuid, res);
            });
        }
    }

    #[sqlx::test(fixtures("meal", "allergen", "additive"))]
    async fn test_get_similar_meal(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool };

        let addons: HashMap<&str, (Vec<Additive>, Vec<Allergen>)> = HashMap::from([
            ("f7337122-b018-48ad-b420-6202dc3cb4ff", (vec![], vec![We])),
            ("73cf367b-a536-4b49-ad0c-cb984caa9a08", (vec![], vec![])),
            ("1b5633c2-05c5-4444-90e5-2e475bae6463", (vec![PreservingAgents, AntioxidantAgents], vec![ML, Se, So])),
        ]);

        let tests = [
            // Identical
            (Uuid::parse_str("f7337122-b018-48ad-b420-6202dc3cb4ff").unwrap(), "Geflügel - Cevapcici, Ajvar, Djuvec Reis", true),
            (Uuid::parse_str("73cf367b-a536-4b49-ad0c-cb984caa9a08").unwrap(), "zu jedem Gericht reichen wir ein Dessert oder Salat", true),
            (Uuid::parse_str("1b5633c2-05c5-4444-90e5-2e475bae6463").unwrap(), "Cordon bleu vom Schwein mit Bratensoße", true),

            // 'Similar' with identical addons
            (Uuid::parse_str("61b27158-817c-4716-bd41-2a8901391ea4").unwrap(), "line2", true),
            (Uuid::parse_str("119c55b7-e539-4849-bad1-984efff2aad6").unwrap(), "sing. line", true),
            (Uuid::parse_str("a4956171-a5fc-4c6b-a028-3cb2e5d2bedb").unwrap(), "spec. line", true),

            // No longer 'similar' with identical addons
            // TODO threshold wont work: All results under the threshold should be ignored.
            (Uuid::default(), "line", false),
            (Uuid::default(), "sing.", false),
            (Uuid::default(), "", false),
        ];

        for (uuid, name, is_similar) in tests {
            println!("Testing values: '{uuid}', '{name}'. Should be similar: {is_similar}");
            let (additives, allergens) = addons.get(&*uuid.to_string()).unwrap();
            req.get_similar_meal(name, allergens, additives).await.unwrap().map_or_else(|| {// TODO unwrap error as operator does not exist in query
                println!("{is_similar}");
                assert!(!is_similar);
            }, |res| {
                println!("{res}");
                assert_eq!(uuid, res);
            });
        }
    }

    #[sqlx::test(fixtures("canteen", "line", "meal", "food_plan"))]
    async fn test_add_to_plan(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };
        let food_id = Uuid::parse_str("25cb8c50-75a4-48a2-b4cf-8ab2566d8bec").unwrap();
        let line_id = Uuid::parse_str("119c55b7-e539-4849-bad1-984efff2aad6").unwrap();
        let date = Utc::now().date_naive();
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
            line_id, food_id, date
        ).fetch_all(&pool).await.unwrap();
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

        let meal_type = MealType::Vegan;
        let name = "TEST_FOOD";
        let additives = vec![
            Additive::Alcohol
        ];
        let allergens = vec![
            Allergen::Ca, Allergen::Pa
        ];

        let res = req.insert_food(name, meal_type, &allergens, &additives).await;
        //assert!(res.is_ok());
        let food_id = res.unwrap();

        let db_additives = sqlx::query_scalar!(
            r#"SELECT additive as "additive: Additive" FROM food_additive WHERE food_id = $1"#,
            food_id
        ).fetch_all(&pool).await.unwrap();
        assert_eq!(db_additives, additives);

        let db_allergens = sqlx::query_scalar!(
            r#"SELECT allergen as "allergen: Allergen" FROM food_allergen WHERE food_id = $1"#,
            food_id
        ).fetch_all(&pool).await.unwrap();
        assert_eq!(db_allergens, allergens);


        let selections = sqlx::query!(r#"SELECT name, food_type as "meal_type: MealType" FROM food WHERE food_id = $1"#, food_id).fetch_all(&pool).await.unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.meal_type, meal_type);
    }

    #[sqlx::test(fixtures("canteen"))]
    async fn test_insert_canteen(pool: PgPool) {
        let req = PersistentMealplanManagementData { pool: pool.clone() };

        let name = "TEST_CANTEEN";
        let pos = 42_u32;

        let res = req.insert_canteen(name, pos).await;
        assert!(res.is_ok());
        let canteen_id = res.unwrap();

        let selections = sqlx::query!(r#"SELECT name, position FROM canteen WHERE canteen_id = $1"#, canteen_id).fetch_all(&pool).await.unwrap();
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

        let res = req.insert_line(canteen_id, name, pos).await; // TODO insert canteen_id
        assert!(res.is_ok());
        let line_id = res.unwrap();

        let selections = sqlx::query!(r#"SELECT name, position FROM line WHERE line_id = $1"#, line_id).fetch_all(&pool).await.unwrap();
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

        let selections = sqlx::query!(r#"SELECT name FROM food WHERE food_id = $1"#, food_id).fetch_all(&pool).await.unwrap();
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
        let canteen_id = res.unwrap();

        let selections = sqlx::query!(r#"SELECT name, position FROM canteen WHERE canteen_id = $1"#, canteen_id).fetch_all(&pool).await.unwrap();
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
        let line_id = res.unwrap();

        let selections = sqlx::query!(r#"SELECT name, position FROM line WHERE line_id = $1"#, line_id).fetch_all(&pool).await.unwrap();
        let selection = selections.first().unwrap();

        assert_eq!(selection.name, name);
        assert_eq!(selection.position as u32, pos);
    }

}