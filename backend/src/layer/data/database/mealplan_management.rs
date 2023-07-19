use async_trait::async_trait;

use crate::{
    interface::persistent_data::{
        model::{Canteen, Line, Meal, Side},
        Result,
        MealplanManagementDataAccess,
    },
    util::{Date, Allergen, Additive, Uuid, MealType, Price},
};

pub struct PersistentMealplanManagementData;

#[async_trait]
impl MealplanManagementDataAccess for PersistentMealplanManagementData {
    async fn dissolve_relations(&self, canteen: Canteen, date: Date) {
        todo!()
    }
    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Canteen>> {
        todo!()
    }
    async fn get_similar_line(&self, similar_name: &str) -> Result<Option<Line>> {
        todo!()
    }
    async fn get_similar_meal(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Meal>> {
        todo!()
    }
    async fn get_similar_side(
        &self,
        similar_name: &str,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Option<Side>> {
        todo!()
    }

    async fn update_canteen(&self, uuid: Uuid, name: &str) -> Result<Canteen> {
        todo!()
    }
    async fn update_line(&self, uuid: Uuid, name: &str) -> Result<Line> {
        todo!()
    }
    async fn update_meal(
        &self,
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: &str,
        price: Price,
    ) -> Result<Meal> {
        todo!()
    }
    async fn update_side(
        &self,
        uuid: Uuid,
        line_id: Uuid,
        date: Date,
        name: &str,
        price: Price,
    ) -> Result<Side> {
        todo!()
    }

    async fn insert_canteen(&self, name: &str) -> Result<Canteen> {
        todo!()
    }
    async fn insert_line(&self, name: &str) -> Result<Line> {
        todo!()
    }
    async fn insert_meal(
        &self,
        name: &str,
        meal_type: MealType,
        price: Price,
        next_served: Date,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Meal> {
        todo!()
    }
    async fn insert_side(
        &self,
        name: &str,
        meal_type: MealType,
        price: Price,
        next_served: Date,
        allergens: &[Allergen],
        additives: &[Additive],
    ) -> Result<Side> {
        todo!()
    }
}
