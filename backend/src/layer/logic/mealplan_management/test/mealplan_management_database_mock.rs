//! This crate contains mocks of [`MealplanManagementDatabaseMock`] for testing.
use crate::{
    interface::{
        mensa_parser::model::ParseEnvironmentInfo,
        persistent_data::{MealplanManagementDataAccess, Result},
    },
    util::{Additive, Allergen, Date, FoodType, NutritionData, Price, Uuid},
};
use async_trait::async_trait;

/// Mock of [`MealplanManagementDataAccess`]
pub struct MealplanManagementDatabaseMock;

fn gen_random_uuid() -> Uuid {
    Uuid::new_v4()
}

#[async_trait]
impl MealplanManagementDataAccess for MealplanManagementDatabaseMock {
    async fn dissolve_relations(&self, _canteen: Uuid, _date: Date) -> Result<()> {
        Ok(())
    }

    async fn get_similar_canteen(&self, _similar_name: &str) -> Result<Option<Uuid>> {
        Ok(Option::from(gen_random_uuid()))
    }

    async fn get_similar_line(
        &self,
        _similar_name: &str,
        _canteen_id: Uuid,
    ) -> Result<Option<Uuid>> {
        Ok(None)
    }

    async fn get_similar_meal(
        &self,
        _similar_name: &str,
        _food_type: FoodType,
        _allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        Ok(None)
    }

    async fn get_similar_side(
        &self,
        _similar_name: &str,
        _food_type: FoodType,
        _allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Option<Uuid>> {
        Ok(None)
    }

    async fn update_canteen(&self, _uuid: Uuid, _name: &str, _position: u32) -> Result<()> {
        Ok(())
    }

    async fn update_line(&self, _uuid: Uuid, _name: &str, _position: u32) -> Result<()> {
        Ok(())
    }

    async fn update_meal(
        &self,
        _uuid: Uuid,
        _name: &str,
        _nutrition_data: Option<NutritionData>,
        _parse_environment_info: Option<ParseEnvironmentInfo>,
    ) -> Result<()> {
        Ok(())
    }

    async fn update_side(
        &self,
        _uuid: Uuid,
        _name: &str,
        _nutrition_data: Option<NutritionData>,
        _parse_environment_info: Option<ParseEnvironmentInfo>,
    ) -> Result<()> {
        Ok(())
    }

    async fn insert_canteen(&self, _name: &str, _position: u32) -> Result<Uuid> {
        Ok(gen_random_uuid())
    }

    async fn insert_line(&self, _canteen_id: Uuid, _name: &str, _position: u32) -> Result<Uuid> {
        Ok(gen_random_uuid())
    }

    async fn insert_meal(
        &self,
        _name: &str,
        _food_type: FoodType,
        _allergens: &[Allergen],
        _additives: &[Additive],
        _nutrition_data: Option<NutritionData>,
        _environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid> {
        Ok(gen_random_uuid())
    }

    async fn insert_side(
        &self,
        _name: &str,
        _food_type: FoodType,
        _allergens: &[Allergen],
        _additives: &[Additive],
        _nutrition_data: Option<NutritionData>,
        _environment_information: Option<ParseEnvironmentInfo>,
    ) -> Result<Uuid> {
        Ok(gen_random_uuid())
    }

    async fn add_meal_to_plan(
        &self,
        _meal_id: Uuid,
        _line_id: Uuid,
        _date: Date,
        _price: Price,
    ) -> Result<()> {
        Ok(())
    }

    async fn add_side_to_plan(
        &self,
        _side_id: Uuid,
        _line_id: Uuid,
        _date: Date,
        _price: Price,
    ) -> Result<()> {
        Ok(())
    }
}
