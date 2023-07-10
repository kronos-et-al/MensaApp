//! This crate contains mocks of [`MealplanManagementDatabaseMock`] for testing.

use async_trait::async_trait;

use crate::{
    interface::persistent_data::{
        model::{Canteen, Line, Meal, Side},
        MealplanManagementDataAccess, Result,
    },
    util::{
        Additive, Allergen, Date,
        MealType::{self, Vegan},
        Price, Uuid,
    },
};

const fn get_price() -> Price {
    Price {
        price_student: 0,
        price_employee: 0,
        price_guest: 0,
        price_pupil: 0,
    }
}

const fn get_price_by_reference(price: &Price) -> Price {
    Price {
        price_student: price.price_student,
        price_employee: price.price_employee,
        price_guest: price.price_guest,
        price_pupil: price.price_pupil
    }
}

fn get_side() -> Side {
    Side {
        id: Uuid::default(),
        name: String::new(),
        meal_type: Vegan,
        price: get_price(),
    }
}

fn get_sides(name: &str, side_amount: u32) -> Vec<Side> {
    let mut sides = Vec::new();
    for i in 1..side_amount {
        let mut side = get_side();
        side.name = format!("{name} {i}");
        sides.push(side);
    }
    sides
}

fn get_meal() -> Meal {
    Meal {
        id: Uuid::default(),
        name: String::new(),
        meal_type: Vegan,
        price: get_price(),
        last_served: None,
        next_served: None,
        relative_frequency: 0.0,
        rating_count: 0,
        average_rating: 0.0,
        date: Date::default(),
        line_id: Uuid::default(),
    }
}

fn get_meals(name: &str, meal_amount: u32) -> Vec<Meal> {
    let mut meals: Vec<Meal> = Vec::new();
    for i in 1..meal_amount {
        let mut meal = get_meal();
        meal.name = format!("{name} {i}");
        meals.push(meal);
    }
    meals
}

fn get_line() -> Line {
    Line {
        id: Uuid::default(),
        name: String::new(),
        canteen_id: Uuid::default(),
    }
}

fn get_lines(name: &str, line_amount: u32) -> Vec<Line> {
    let mut lines = Vec::new();
    for i in 1..line_amount {
        let mut line = get_line();
        line.name = format!("{name} {i}");
        lines.push(line);
    }
    lines
}

fn get_canteen() -> Canteen {
    Canteen {
        id: Uuid::default(),
        name: String::new(),
    }
}

fn get_canteens(name: &str, canteen_amount: u32) -> Vec<Canteen> {
    let mut canteens = Vec::new();
    for i in 1..canteen_amount {
        let mut canteen = get_canteen();
        canteen.name = format!("{name} {i}");
        canteens.push(canteen);
    }
    canteens
}

pub struct MealplanManagementDatabaseMock;

#[async_trait]
impl MealplanManagementDataAccess for MealplanManagementDatabaseMock {
    //TODO update similar function mocks

    /// Determines all canteens with a similar name.
    async fn get_similar_canteen(&self, similar_name: &str) -> Result<Option<Canteen>> {
        Ok(get_canteens(similar_name, 10).pop())
    }
    /// Determines all lines with a similar name.
    async fn get_similar_line(&self, similar_name: &str) -> Result<Option<Line>> {
        Ok(get_lines(similar_name, 5).pop())
    }
    /// Determines all meals with a similar name.
    async fn get_similar_meal(&self, similar_name: &str) -> Result<Option<Meal>> {
        Ok(get_meals(similar_name, 2).pop())
    }
    /// Determines all sides with a similar name.
    async fn get_similar_side(&self, similar_name: &str) -> Result<Option<Side>> {
        Ok(get_sides(similar_name, 3).pop())
    }

    /// Updates an existing canteen entity in the database. Returns the entity.
    async fn update_canteen(&self, id: Uuid, name: &str) -> Result<Canteen> {
        let s_name = name.to_string();
        let canteen = Canteen { id, name: s_name };
        Ok(canteen)
    }
    /// Updates an existing line entity in the database. Returns the entity.
    async fn update_line(&self, id: Uuid, name: &str) -> Result<Line> {
        let line = Line {
            id,
            name: name.to_string(),
            ..get_line()
        };
        Ok(line)
    }
    /// Updates an existing meal entity in the database. Returns the entity.
    async fn update_meal(
        &self,
        id: Uuid,
        _line_id: Uuid,
        _date: Date,
        name: &str,
        price: &Price,
    ) -> Result<Meal> {
        let meal = Meal {
            id,
            name: name.to_string(),
            price: get_price_by_reference(price),
            ..get_meal()
        };
        Ok(meal)
    }
    /// Updates an existing side entity in the database. Returns the entity.
    async fn update_side(
        &self,
        id: Uuid,
        _line_id: Uuid,
        _date: Date,
        name: &str,
        price: &Price,
    ) -> Result<Side> {
        let side = Side {
            id,
            name: name.to_string(),
            price: get_price_by_reference(price),
            ..get_side()
        };
        Ok(side)
    }

    /// Adds a new canteen entity to the database. Returns the new entity.
    async fn insert_canteen(&self, name: &str) -> Result<Canteen> {
        let canteen = Canteen {
            name: name.to_string(),
            ..get_canteen()
        };
        Ok(canteen)
    }
    /// Adds a new line entity to the database. Returns the new entity.
    async fn insert_line(&self, name: &str) -> Result<Line> {
        let line = Line { name: name.to_string(), ..get_line() };
        Ok(line)
    }
    /// Adds a new meal entity to the database. Returns the new entity.
    async fn insert_meal(
        &self,
        name: &str,
        meal_type: MealType,
        price: &Price,
        next_served: Date,
        _allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Meal> {
        let meal = Meal {
            name: name.to_string(),
            meal_type,
            price: get_price_by_reference(price),
            next_served: Some(next_served),
            ..get_meal()
        };
        Ok(meal)
    }
    /// Adds a new side entity to the database. Returns the new entity.
    async fn insert_side(
        &self,
        name: &str,
        meal_type: MealType,
        price: &Price,
        _next_served: Date,
        _allergens: &[Allergen],
        _additives: &[Additive],
    ) -> Result<Side> {
        let side = Side {
            name: name.to_string(),
            meal_type,
            price: get_price_by_reference(price),
            ..get_side()
        };
        Ok(side)
    }
}
