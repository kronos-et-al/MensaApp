//! This crate contains mocks of [`RequestDataAccess`] and [`Command`] for testing.
#![allow(missing_docs)]

use async_trait::async_trait;
use uuid::Uuid;

use crate::interface::persistent_data::model::EnvironmentInfo;
use crate::util::{Additive, Allergen, Date, FoodType, Price, ReportReason};
use crate::{
    interface::{
        api_command::{Command, Result as CommandResult},
        persistent_data::{
            model::{ApiKey, Canteen, Image, Line, Meal, Side},
            AuthDataAccess, RequestDataAccess, Result as DataResult,
        },
    },
    util::NutritionData,
};

const INVALID_UUID: &str = "invalid uuid:";

pub struct RequestDatabaseMock;

#[async_trait]
impl RequestDataAccess for RequestDatabaseMock {
    async fn get_canteen(&self, _id: Uuid) -> DataResult<Option<Canteen>> {
        let canteen = Canteen {
            id: Uuid::parse_str("87a75452-c553-4575-8136-508ca874897d").expect(INVALID_UUID),
            name: "dummy_canteen_1".to_string(),
        };
        Ok(Option::from(canteen))
    }

    async fn get_canteens(&self) -> DataResult<Vec<Canteen>> {
        let canteen1 = Canteen {
            id: Uuid::parse_str("87a75452-c553-4575-8136-508ca874897d").expect(INVALID_UUID),
            name: "dummy_canteen_1".to_string(),
        };
        let canteen2 = Canteen {
            id: Uuid::parse_str("b59630fe-b2f7-49d4-80d9-54600ae6fe88").expect(INVALID_UUID),
            name: "dummy_canteen_2".to_string(),
        };
        let canteen3 = Canteen {
            id: Uuid::parse_str("0ce81fa1-003f-40f9-9019-8e9d1864f042").expect(INVALID_UUID),
            name: "dummy_canteen_3".to_string(),
        };
        Ok(vec![canteen1, canteen2, canteen3])
    }

    async fn get_line(&self, _id: crate::util::Uuid) -> DataResult<Option<Line>> {
        let line = Line {
            id: Uuid::parse_str("993cc4f4-8d32-491a-8e19-e9a7a6b6d31e").expect(INVALID_UUID),
            name: "dummy_getLine".to_string(),
            canteen_id: Uuid::parse_str("87a75452-c553-4575-8136-508ca874897d")
                .expect(INVALID_UUID),
        };
        Ok(Option::from(line))
    }

    async fn get_lines(&self, _canteen_id: Uuid) -> DataResult<Vec<Line>> {
        let line1 = Line {
            id: Uuid::parse_str("993cc4f4-8d32-491a-8e19-e9a7a6b6d31e").expect(INVALID_UUID),
            name: "dummy_line_1".to_string(),
            canteen_id: Uuid::parse_str("87a75452-c553-4575-8136-508ca874897d")
                .expect(INVALID_UUID),
        };
        let line2 = Line {
            id: Uuid::parse_str("45ade685-ee81-48d3-a07f-cacf96adff10").expect(INVALID_UUID),
            name: "dummy_line_2".to_string(),
            canteen_id: Uuid::parse_str("87a75452-c553-4575-8136-508ca874897d")
                .expect(INVALID_UUID),
        };
        let line3 = Line {
            id: Uuid::parse_str("2c9a73e7-9c35-4716-b8a7-963e148013f3").expect(INVALID_UUID),
            name: "dummy_line_3".to_string(),
            canteen_id: Uuid::parse_str("b59630fe-b2f7-49d4-80d9-54600ae6fe88")
                .expect(INVALID_UUID),
        };
        Ok(vec![line1, line2, line3])
    }

    async fn get_meal(&self, _id: Uuid, _line_id: Uuid, _date: Date) -> DataResult<Option<Meal>> {
        let meal = Meal {
            id: Uuid::parse_str("4ab922a0-1622-4813-98a7-954272f74b5c").expect(INVALID_UUID),
            name: "dummy_getMeal".to_string(),
            food_type: FoodType::Vegan,
            price: Price {
                price_student: 0,
                price_employee: 0,
                price_guest: 0,
                price_pupil: 0,
            },
            last_served: Option::from(Date::default()),
            next_served: Option::from(Date::default()),
            frequency: 11,
            new: false,
            rating_count: 0,
            average_rating: 0.0,
            date: Date::from_ymd_opt(2023, 7, 4)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::parse_str("993cc4f4-8d32-491a-8e19-e9a7a6b6d31e").expect(INVALID_UUID),
        };
        Ok(Option::from(meal))
    }

    async fn get_meals(&self, _line_id: Uuid, _date: Date) -> DataResult<Option<Vec<Meal>>> {
        let meal1 = Meal {
            id: Uuid::parse_str("4ab922a0-1622-4813-98a7-954272f74b5c").expect(INVALID_UUID),
            name: "dummy_meal_1".to_string(),
            food_type: FoodType::Vegan,
            price: Price {
                price_student: 210,
                price_employee: 2100,
                price_guest: 21000,
                price_pupil: 21,
            },
            last_served: Option::from(Date::default()),
            next_served: Option::from(Date::default()),
            frequency: 0,
            new: true,
            rating_count: 10,
            average_rating: 1.2,
            date: Date::from_ymd_opt(2023, 7, 4)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::parse_str("993cc4f4-8d32-491a-8e19-e9a7a6b6d31e").expect(INVALID_UUID),
        };
        let meal2 = Meal {
            id: Uuid::parse_str("5fa5b832-a685-4b11-b475-f63e9844d299").expect(INVALID_UUID),
            name: "dummy_meal_2".to_string(),
            food_type: FoodType::BeefAw,
            price: Price {
                price_student: 2,
                price_employee: 20,
                price_guest: 200,
                price_pupil: 2000,
            },
            last_served: Option::from(Date::default()),
            next_served: Option::from(Date::default()),
            frequency: 34,
            new: false,
            rating_count: 3,
            average_rating: 4.1,
            date: Date::from_ymd_opt(2022, 6, 5)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::parse_str("993cc4f4-8d32-491a-8e19-e9a7a6b6d31e").expect(INVALID_UUID),
        };
        let meal3 = Meal {
            id: Uuid::parse_str("5035415d-869b-4a89-ad65-d812c781d287").expect(INVALID_UUID),
            name: "dummy_meal_3".to_string(),
            food_type: FoodType::Vegetarian,
            price: Price {
                price_student: 42000,
                price_employee: 4200,
                price_guest: 420,
                price_pupil: 42,
            },
            last_served: Option::from(Date::default()),
            next_served: Option::from(Date::default()),
            frequency: 10,
            new: false,
            rating_count: 7,
            average_rating: 3.5,
            date: Date::from_ymd_opt(2022, 12, 12)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::parse_str("45ade685-ee81-48d3-a07f-cacf96adff10").expect(INVALID_UUID),
        };
        Ok(Some(vec![meal1, meal2, meal3]))
    }

    async fn get_sides(&self, _line_id: Uuid, _date: Date) -> DataResult<Vec<Side>> {
        let side1 = Side {
            id: Uuid::parse_str("5ae5f6da-a9f8-4754-8e7a-e07dc79acf18").expect(INVALID_UUID),
            name: "dummy_side_1".to_string(),
            food_type: FoodType::Vegan,
            price: Price {
                price_student: 320,
                price_employee: 300,
                price_guest: 290,
                price_pupil: 280,
            },
        };
        let side2 = Side {
            id: Uuid::parse_str("51496908-017d-4874-901b-95660abe5776").expect(INVALID_UUID),
            name: "dummy_side_2".to_string(),
            food_type: FoodType::Fish,
            price: Price {
                price_student: 500,
                price_employee: 540,
                price_guest: 220,
                price_pupil: 450,
            },
        };
        let side3 = Side {
            id: Uuid::parse_str("b75340a4-4064-4417-a868-5e602f15a884").expect(INVALID_UUID),
            name: "dummy_side_3".to_string(),
            food_type: FoodType::Beef,
            price: Price {
                price_student: 120,
                price_employee: 130,
                price_guest: 140,
                price_pupil: 200,
            },
        };
        Ok(vec![side1, side2, side3])
    }

    async fn get_visible_images(
        &self,
        _meal_id: Uuid,
        _client_id: Option<Uuid>,
    ) -> DataResult<Vec<Image>> {
        let d1 = Image {
            id: Uuid::parse_str("be7a7c58-1fd3-4432-9669-e87603629aeb").expect(INVALID_UUID),
            rank: 0.1,
            upvotes: 220,
            downvotes: 20,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
            meal_id: Uuid::default(),
        };
        let d2 = Image {
            id: Uuid::parse_str("e4e1c2f5-881c-4e1f-8618-ca8f6f3bf1d2").expect(INVALID_UUID),
            rank: 0.4,
            upvotes: 11,
            downvotes: 4,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
            meal_id: Uuid::default(),
        };
        let d3 = Image {
            id: Uuid::parse_str("9f0a4fb0-c233-4a16-8f3a-2bbbf735ef07").expect(INVALID_UUID),
            rank: 0.6,
            upvotes: 20,
            downvotes: 45,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
            meal_id: Uuid::default(),
        };
        Ok(vec![d1, d2, d3])
    }

    async fn get_personal_rating(
        &self,
        _meal_id: Uuid,
        _client_id: Uuid,
    ) -> DataResult<Option<u32>> {
        Ok(Option::from(42))
    }

    async fn get_personal_upvote(&self, _image_id: Uuid, _client_id: Uuid) -> DataResult<bool> {
        Ok(true)
    }

    async fn get_personal_downvote(&self, _image_id: Uuid, _client_id: Uuid) -> DataResult<bool> {
        Ok(true)
    }

    async fn get_additives(&self, _food_id: crate::util::Uuid) -> DataResult<Vec<Additive>> {
        Ok(vec![
            Additive::Alcohol,
            Additive::Sulphur,
            Additive::Sweetener,
        ])
    }

    async fn get_allergens(&self, _food_id: crate::util::Uuid) -> DataResult<Vec<Allergen>> {
        Ok(vec![Allergen::Pi, Allergen::Hf, Allergen::Gl])
    }

    async fn get_nutrition_data(&self, _food_id: Uuid) -> DataResult<Option<NutritionData>> {
        Ok(Some(NutritionData {
            energy: 1,
            protein: 2,
            carbohydrates: 3,
            sugar: 4,
            fat: 5,
            saturated_fat: 6,
            salt: 7,
        }))
    }

    async fn get_environment_information(
        &self,
        _food_id: Uuid,
    ) -> DataResult<Option<EnvironmentInfo>> {
        Ok(Some(EnvironmentInfo {
            average_rating: 0,
            co2_rating: 1,
            co2_value: 2,
            water_rating: 3,
            water_value: 4,
            animal_welfare_rating: 5,
            rainforest_rating: 6,
            max_rating: 7,
        }))
    }
}

pub struct CommandMock;

#[async_trait]
impl Command for CommandMock {
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(
        &self,
        _image_id: Uuid,
        _reason: ReportReason,
        _client_id: Uuid,
    ) -> CommandResult<()> {
        Ok(())
    }

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, _image_id: Uuid, _client_id: Uuid) -> CommandResult<()> {
        Ok(())
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, _image_id: Uuid, _client_id: Uuid) -> CommandResult<()> {
        Ok(())
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(&self, _image_id: Uuid, _client_id: Uuid) -> CommandResult<()> {
        Ok(())
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(&self, _image_id: Uuid, _client_id: Uuid) -> CommandResult<()> {
        Ok(())
    }

    /// Command to link an image to a meal.
    async fn add_image(
        &self,
        _meal_id: Uuid,
        file_type: Option<String>,
        file: Vec<u8>,
        _client_id: Uuid,
    ) -> CommandResult<()> {
        println!("image type: {file_type:?}, len: {}", file.len());
        Ok(())
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(
        &self,
        _meal_id: Uuid,
        _rating: u32,
        _client_id: Uuid,
    ) -> CommandResult<()> {
        Ok(())
    }
}

pub struct AuthDataMock;

#[async_trait]
impl AuthDataAccess for AuthDataMock {
    async fn get_api_keys(&self) -> DataResult<Vec<ApiKey>> {
        Ok(vec![
            ApiKey {
                key: "1234567890".into(),
                description: String::new(),
            },
            ApiKey {
                key: "YWpzZGg4MnozNzhkMnppZGFzYXNkMiBzYWZzYSBzPGE5MDk4".into(),
                description: String::new(),
            },
        ])
    }
}
