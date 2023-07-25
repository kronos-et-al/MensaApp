//! This crate contains mocks of [`RequestDataAccess`] and [`Command`] for testing.

use async_trait::async_trait;
use chrono::NaiveDate;
use uuid::Uuid;

use crate::util::{Additive, Allergen, MealType, Price};
use crate::{
    interface::{
        api_command::{AuthInfo, Command, Result as CommandResult},
        persistent_data::{
            model::{Canteen, Image, Line, Meal, Side},
            RequestDataAccess, Result as DataResult,
        },
    },
    util::{Date, ReportReason},
};

pub struct RequestDatabaseMock;

#[async_trait]
impl RequestDataAccess for RequestDatabaseMock {
    async fn get_canteen(&self, _id: Uuid) -> DataResult<Option<Canteen>> {
        let canteen = Canteen {
            id: Uuid::default(),
            name: "dummy_getCanteen".to_string(),
        };
        Ok(Option::from(canteen))
    }

    async fn get_canteens(&self) -> DataResult<Vec<Canteen>> {
        let canteen1 = Canteen {
            id: Uuid::default(),
            name: "dummy_canteen_1".to_string(),
        };
        let canteen2 = Canteen {
            id: Uuid::default(),
            name: "dummy_canteen_2".to_string(),
        };
        let canteen3 = Canteen {
            id: Uuid::default(),
            name: "dummy_canteen_3".to_string(),
        };
        Ok(vec![canteen1, canteen2, canteen3])
    }

    async fn get_line(&self, _id: crate::util::Uuid) -> DataResult<Option<Line>> {
        let line = Line {
            id: Uuid::default(),
            name: "dummy_getLine".to_string(),
            canteen_id: Uuid::default(),
        };
        Ok(Option::from(line))
    }

    async fn get_lines(&self, _canteen_id: Uuid) -> DataResult<Vec<Line>> {
        let line1 = Line {
            id: Uuid::default(),
            name: "dummy_line_1".to_string(),
            canteen_id: Uuid::default(),
        };
        let line2 = Line {
            id: Uuid::default(),
            name: "dummy_line_2".to_string(),
            canteen_id: Uuid::default(),
        };
        let line3 = Line {
            id: Uuid::default(),
            name: "dummy_line_3".to_string(),
            canteen_id: Uuid::default(),
        };
        Ok(vec![line1, line2, line3])
    }

    async fn get_meal(&self, _id: Uuid, _line_id: Uuid, _date: Date) -> DataResult<Option<Meal>> {
        let meal = Meal {
            id: Uuid::default(),
            name: "dummy_getMeal".to_string(),
            meal_type: MealType::Vegan,
            price: Price {
                price_student: 0,
                price_employee: 0,
                price_guest: 0,
                price_pupil: 0,
            },
            last_served: Option::from(NaiveDate::default()),
            next_served: Option::from(NaiveDate::default()),
            frequency: 11,
            new: false,
            rating_count: 0,
            average_rating: 0.0,
            date: Date::from_ymd_opt(2023, 7, 4)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::default(),
        };
        Ok(Option::from(meal))
    }

    async fn get_meals(&self, _line_id: Uuid, _date: Date) -> DataResult<Option<Vec<Meal>>> {
        let meal1 = Meal {
            id: Uuid::default(),
            name: "dummy_meal_1".to_string(),
            meal_type: MealType::Vegan,
            price: Price {
                price_student: 210,
                price_employee: 2100,
                price_guest: 21000,
                price_pupil: 21,
            },
            last_served: Option::from(NaiveDate::default()),
            next_served: Option::from(NaiveDate::default()),
            frequency: 0,
            new: true,
            rating_count: 10,
            average_rating: 1.2,
            date: Date::from_ymd_opt(2023, 7, 4)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::default(),
        };
        let meal2 = Meal {
            id: Uuid::default(),
            name: "dummy_meal_2".to_string(),
            meal_type: MealType::BeefAw,
            price: Price {
                price_student: 2,
                price_employee: 20,
                price_guest: 200,
                price_pupil: 2000,
            },
            last_served: Option::from(NaiveDate::default()),
            next_served: Option::from(NaiveDate::default()),
            frequency: 34,
            new: false,
            rating_count: 3,
            average_rating: 4.1,
            date: Date::from_ymd_opt(2022, 6, 5)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::default(),
        };
        let meal3 = Meal {
            id: Uuid::default(),
            name: "dummy_meal_3".to_string(),
            meal_type: MealType::Vegetarian,
            price: Price {
                price_student: 42000,
                price_employee: 4200,
                price_guest: 420,
                price_pupil: 42,
            },
            last_served: Option::from(NaiveDate::default()),
            next_served: Option::from(NaiveDate::default()),
            frequency: 10,
            new: false,
            rating_count: 7,
            average_rating: 3.5,
            date: Date::from_ymd_opt(2022, 12, 12)
                .expect("Date not could be created with these parameters."),
            line_id: Uuid::default(),
        };
        Ok(Some(vec![meal1, meal2, meal3]))
    }

    async fn get_sides(&self, _line_id: Uuid, _date: Date) -> DataResult<Vec<Side>> {
        let side1 = Side {
            id: Uuid::default(),
            name: "dummy_side_1".to_string(),
            meal_type: MealType::Vegan,
            price: Price {
                price_student: 320,
                price_employee: 300,
                price_guest: 290,
                price_pupil: 280,
            },
        };
        let side2 = Side {
            id: Uuid::default(),
            name: "dummy_side_2".to_string(),
            meal_type: MealType::Fish,
            price: Price {
                price_student: 500,
                price_employee: 540,
                price_guest: 220,
                price_pupil: 450,
            },
        };
        let side3 = Side {
            id: Uuid::default(),
            name: "dummy_side_3".to_string(),
            meal_type: MealType::Beef,
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
            id: Uuid::default(),
            image_hoster_id: "dummy_image1_id".to_string(),
            url: String::new(),
            rank: 0.1,
            upvotes: 220,
            downvotes: 20,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
        };
        let d2 = Image {
            id: Uuid::default(),
            image_hoster_id: "dummy_image2_id".to_string(),
            url: String::new(),
            rank: 0.4,
            upvotes: 11,
            downvotes: 4,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
        };
        let d3 = Image {
            id: Uuid::default(),
            image_hoster_id: "dummy_image3_id".to_string(),
            url: String::new(),
            rank: 0.6,
            upvotes: 20,
            downvotes: 45,
            report_count: 0,
            approved: false,
            upload_date: Date::default(),
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
}

pub struct CommandMock;

#[async_trait]
impl Command for CommandMock {
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(
        &self,
        _image_id: Uuid,
        _reason: ReportReason,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Ok(())
    }

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, _image_id: Uuid, _auth_info: AuthInfo) -> CommandResult<()> {
        Ok(())
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, _image_id: Uuid, _auth_info: AuthInfo) -> CommandResult<()> {
        Ok(())
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(
        &self,
        _image_id: Uuid,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Ok(())
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(
        &self,
        _image_id: Uuid,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Ok(())
    }

    /// Command to link an image to a meal.
    async fn add_image(
        &self,
        _meal_id: Uuid,
        _image_url: String,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Ok(())
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(
        &self,
        _meal_id: Uuid,
        _rating: u32,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Ok(())
    }
}
