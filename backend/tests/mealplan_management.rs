use std::{env, fs};
use axum::response::Html;
use axum::Router;
use axum::routing::get;
use chrono::{Datelike, Local};
use dotenvy::dotenv;
use mensa_app_backend::{
    layer::{
        data::{
            database::factory::DataAccessFactory,
        },
    },
    startup::config::ConfigReader,
};
use mensa_app_backend::layer::data::database::mealplan_management::PersistentMealplanManagementData;
use mensa_app_backend::layer::data::swka_parser::swka_parse_manager::SwKaParseManager;
use mensa_app_backend::layer::logic::mealplan_management::meal_plan_manager::MealPlanManager;

async fn setup() -> MealPlanManager<SwKaParseManager, PersistentMealplanManagementData> {
    dotenv().ok();
    assert_eq!(env::var("MENSA_BASE_URL").unwrap(), "http://localhost:3000");
    assert_eq!(env::var("CANTEENS").unwrap(), "canteen1,canteen2,canteen3");

    setup_local_webserver().await;

    let reader = ConfigReader::default();
    let mensa_parser = SwKaParseManager::new(reader.read_swka_info().unwrap()).unwrap();

    let factory = DataAccessFactory::new(reader.read_database_info().unwrap(), true).await.unwrap();
    let data = factory.get_mealplan_management_data_access();
    MealPlanManager::new(data, mensa_parser)
}

async fn setup_router() -> Router {
    let cur_calender_week = Local::now().date_naive().iso_week().week();
    let next_calender_week = cur_calender_week + 1;
    let second_next_calender_week = cur_calender_week + 2;
    let third_next_calender_week = cur_calender_week + 3;

    Router::new()
        .route(&format!("/canteen1/?kw={cur_calender_week}"), get(canteen1_w1))
        .route(&format!("/canteen1/?kw={next_calender_week}"), get(canteen1_w2))
        .route(&format!("/canteen1/?kw={second_next_calender_week}"), get(canteen1_w3))
        .route(&format!("/canteen1/?kw={third_next_calender_week}"), get(canteen1_w4))
        .route(&format!("/canteen2/?kw={cur_calender_week}"), get(canteen2_w1))
        .route(&format!("/canteen2/?kw={next_calender_week}"), get(canteen2_w2))
        .route(&format!("/canteen2/?kw={second_next_calender_week}"), get(canteen2_w3))
        .route(&format!("/canteen2/?kw={third_next_calender_week}"), get(canteen2_w4))
        .route(&format!("/canteen3/?kw={cur_calender_week}"), get(canteen3_w1))
        .route(&format!("/canteen3/?kw={next_calender_week}"), get(canteen3_w2))
        .route(&format!("/canteen3/?kw={second_next_calender_week}"), get(canteen3_w3))
        .route(&format!("/canteen3/?kw={third_next_calender_week}"), get(canteen3_w4))
}

async fn setup_local_webserver() {
    tokio::spawn(axum::Server::bind(&"0.0.0.0:3000".parse().unwrap())
        .serve(setup_router().await.into_make_service())
    );
}

#[tokio::test]
#[ignore = "manual test"]
async fn start_full_with_empty_db() {
    let mgmt = setup().await;
}

#[tokio::test]
#[ignore = "manual test"]
async fn start_update_with_empty_db() {

}

#[tokio::test]
#[ignore = "manual test"]
async fn start_full_with_filled_db() {

}

#[tokio::test]
#[ignore = "manual test"]
async fn start_update_with_filled_db() {

}

// HANDLER

async fn canteen1_w1() -> Html<String> {
    Html(fs::read_to_string("tests/data/w1_canteen1.html").unwrap())
}
async fn canteen1_w2() -> Html<String> {
    Html(fs::read_to_string("tests/data/w2_canteen1.html").unwrap())
}
async fn canteen1_w3() -> Html<String> {
    Html(fs::read_to_string("tests/data/w3_canteen1.html").unwrap())
}
async fn canteen1_w4() -> Html<String> {
    Html(fs::read_to_string("tests/data/w4_canteen1.html").unwrap())
}
async fn canteen2_w1() -> Html<String> {
    Html(fs::read_to_string("tests/data/w1_canteen2.html").unwrap())
}
async fn canteen2_w2() -> Html<String> {
    Html(fs::read_to_string("tests/data/w2_canteen2.html").unwrap())
}
async fn canteen2_w3() -> Html<String> {
    Html(fs::read_to_string("tests/data/w3_canteen2.html").unwrap())
}
async fn canteen2_w4() -> Html<String> {
    Html(fs::read_to_string("tests/data/w4_canteen2.html").unwrap())
}
async fn canteen3_w1() -> Html<String> {
    Html(fs::read_to_string("tests/data/w1_canteen3.html").unwrap())
}
async fn canteen3_w2() -> Html<String> {
    Html(fs::read_to_string("tests/data/w2_canteen3.html").unwrap())
}
async fn canteen3_w3() -> Html<String> {
    Html(fs::read_to_string("tests/data/w3_canteen3.html").unwrap())
}
async fn canteen3_w4() -> Html<String> {
    Html(fs::read_to_string("tests/data/w4_canteen3.html").unwrap())
}