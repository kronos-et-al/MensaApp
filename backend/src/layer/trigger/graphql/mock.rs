//! This crate contains mocks of [`RequestDataAccess`] and [`Command`] for testing.
use async_trait::async_trait;
use uuid::Uuid;

use crate::{interface::{
    api_command::{Command, AuthInfo, Result as CommandResult},
    persistent_data::{RequestDataAccess, Result as DataResult, model::*},
}, util::{Date, ReportReason}};

pub struct RequestDatabaseMock;

#[async_trait]
impl RequestDataAccess for RequestDatabaseMock {
    async fn get_canteen(id: Uuid) -> DataResult<Option<Canteen>> {
        todo!()
    }

    async fn get_canteens() -> DataResult<Vec<Canteen>> {
        todo!()
    }

    async fn get_lines(canteen_id: Uuid) -> DataResult<Vec<Line>> {
        todo!()
    }

    async fn get_meal(
        id: Uuid,
        line_id: Uuid,
        date: Date,
        client_id: Uuid,
    ) -> DataResult<Option<Meal>> {
        todo!()
    }

    async fn get_meals(
        line_id: Uuid,
        date: Date,
        client_id: Uuid,
    ) -> DataResult<Vec<Meal>> {
        todo!()
    }

    async fn get_sides(line_id: Uuid, date: Date) -> DataResult<Vec<Side>> {
        todo!()
    }

    async fn get_visible_images(meal_id: Uuid, client_id: Option<Uuid>) -> DataResult<Vec<Image>> {
        todo!()
    }

    async fn get_personal_rating(meal_id: Uuid, client_id: Uuid) -> DataResult<Option<u32>> {
        todo!()
    }

    async fn get_personal_upvote(image_id: Uuid, client_id: Uuid) -> DataResult<bool> {
        todo!()
    }

    async fn get_personal_downvote(image_id: Uuid, client_id: Uuid) -> DataResult<bool> {
        todo!()
    }
}

pub struct CommandMock;

#[async_trait]
impl Command for CommandMock {
    /// Command to report an image. It als gets checked whether the image shall get hidden.
    async fn report_image(image_id: Uuid, reason: ReportReason, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to vote up an image. All down-votes of the same user get removed.
    async fn add_image_upvote(image_id: Uuid, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to vote down an image. All up-votes of the same user get removed.
    async fn add_image_downvote(image_id: Uuid, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to remove an up-vote for an image.
    async fn remove_image_upvote(image_id: Uuid, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to remove an down-vote for an image.
    async fn remove_image_downvote(image_id: Uuid, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// Command to link an image to a meal.
    async fn add_image(meal_id: Uuid, image_url: String, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }

    /// command to add a rating to a meal.
    async fn set_meal_rating(meal_id: Uuid, rating: u32, auth_info: AuthInfo) -> CommandResult<()> {
        todo!();
    }
}