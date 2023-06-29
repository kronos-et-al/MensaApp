#![cfg(test)]

use async_trait::async_trait;
use uuid::Uuid;

use crate::interface::{persistent_data::{RequestDataAccess, Result as DataResult}, api_command::Command};

use super::server::GraphQLServer;

struct RequestDatabaseMock;

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
    
    async fn get_meal(id: Uuid, line_id: Uuid, date: Date, client_id: Uuid)
        -> DataResult<Option<Meal>> {
            todo!()
        }
    
    async fn get_meals(line_id: Uuid, date: DateTime<Local>, client_id: Uuid) -> DataResult<Vec<Meal>> {
        todo!()
    }
    
    async fn get_sides(line_id: Uuid, date: DateTime<Local>) -> DataResult<Vec<Side>> {
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


struct CommandMock;

#[async_trait]
impl Command for CommandMock {
    
}

#[tokio::test]
async fn run_server() {
    let server = GraphQLServer::new(RequestDatabaseMock, CommandMock);

}