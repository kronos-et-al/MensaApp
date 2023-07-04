//! This crate contains mocks of [`RequestDataAccess`] and [`Command`] for testing.

use async_trait::async_trait;
use uuid::Uuid;

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
use crate::util::{MealType, Price};

pub struct RequestDatabaseMock;

#[async_trait]
impl RequestDataAccess for RequestDatabaseMock {
    async fn get_canteen(&self, _id: Uuid) -> DataResult<Option<Canteen>> {
        todo!()
    }

    async fn get_canteens(&self) -> DataResult<Vec<Canteen>> {
        todo!()
    }

    async fn get_lines(&self, _canteen_id: Uuid) -> DataResult<Vec<Line>> {
        todo!()
    }

    async fn get_meal(
        &self,
        _id: Uuid,
        _line_id: Uuid,
        _date: Date,
        _client_id: Uuid,
    ) -> DataResult<Option<Meal>> {
        let meal = Meal {
            id: Default::default(),
            name: "".to_string(),
            meal_type: MealType::Vegan,
            price: Price {
                price_student: 0,
                price_employee: 0,
                price_guest: 0,
                price_pupil: 0,
            },
            last_served: Default::default(),
            next_served: Default::default(),
            relative_frequency: 0.0,
            rating_count: 0,
            average_rating: 0.0,
            allergens: vec![],
            additives: vec![],
        };
        Ok(Option::from(meal))
    }

    async fn get_meals(
        &self,
        _line_id: Uuid,
        _date: Date,
        _client_id: Uuid,
    ) -> DataResult<Vec<Meal>> {
        todo!()
    }

    async fn get_sides(&self, _line_id: Uuid, _date: Date) -> DataResult<Vec<Side>> {
        todo!()
    }

    async fn get_visible_images(
        &self,
        _meal_id: Uuid,
        _client_id: Option<Uuid>,
    ) -> DataResult<Vec<Image>> {
        let mut vec = Vec::new();
        let d1 = Image {
            id: Default::default(),
            image_hoster_id: "".to_string(),
            url: "".to_string(),
            rank: 0.0,
            upvotes: 0,
            downvotes: 0,
        };
        vec.push(d1);
        Ok(vec)
    }

    async fn get_personal_rating(
        &self,
        _meal_id: Uuid,
        _client_id: Uuid,
    ) -> DataResult<Option<u32>> {
        Ok(Option::from(42 as u32))
    }

    async fn get_personal_upvote(&self, _image_id: Uuid, _client_id: Uuid) -> DataResult<bool> {
        Ok(true)
    }

    async fn get_personal_downvote(&self, _image_id: Uuid, _client_id: Uuid) -> DataResult<bool> {
        Ok(true)
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
        todo!();
    }

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(&self, _image_id: Uuid, _auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(&self, _image_id: Uuid, _auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(
        &self,
        _image_id: Uuid,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        todo!();
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(
        &self,
        _image_id: Uuid,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        todo!();
    }

    /// Command to link an image to a meal.
    async fn add_image(
        &self,
        _meal_id: Uuid,
        _image_url: String,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        Err(crate::interface::api_command::CommandError::BadAuth)
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(
        &self,
        _meal_id: Uuid,
        _rating: u32,
        _auth_info: AuthInfo,
    ) -> CommandResult<()> {
        todo!();
    }
}
