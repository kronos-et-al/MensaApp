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
    /// Determines all canteens with a similar name.
    async fn get_similar_canteens(&self, similar_name: String) -> Result<Vec<Canteen>> {
        Ok(get_canteens(&similar_name, 10))
    }
    /// Determines all lines with a similar name.
    async fn get_similar_lines(&self, similar_name: String) -> Result<Vec<Line>> {
        Ok(get_lines(&similar_name, 5))
    }
    /// Determines all meals with a similar name.
    async fn get_similar_meals(&self, similar_name: String) -> Result<Vec<Meal>> {
        Ok(get_meals(&similar_name, 2))
    }
    /// Determines all sides with a similar name.
    async fn get_similar_sides(&self, similar_name: String) -> Result<Vec<Side>> {
        Ok(get_sides(&similar_name, 3))
    }

    /// Updates an existing canteen entity in the database. Returns the entity.
    async fn update_canteen(&self, id: Uuid, name: String) -> Result<Canteen> {
        let canteen = Canteen { id, name };
        Ok(canteen)
    }
    /// Updates an existing line entity in the database. Returns the entity.
    async fn update_line(&self, id: Uuid, name: String) -> Result<Line> {
        let line = Line {
            id,
            name,
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
        name: String,
        price: Price,
    ) -> Result<Meal> {
        let meal = Meal {
            id,
            name,
            price,
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
        name: String,
        price: Price,
    ) -> Result<Side> {
        let side = Side {
            id,
            name,
            price,
            ..get_side()
        };
        Ok(side)
    }

    /// Adds a new canteen entity to the database. Returns the new entity.
    async fn insert_canteen(&self, name: String) -> Result<Canteen> {
        let canteen = Canteen {
            name,
            ..get_canteen()
        };
        Ok(canteen)
    }
    /// Adds a new line entity to the database. Returns the new entity.
    async fn insert_line(&self, name: String) -> Result<Line> {
        let line = Line { name, ..get_line() };
        Ok(line)
    }
    /// Adds a new meal entity to the database. Returns the new entity.
    async fn insert_meal(
        &self,
        name: String,
        meal_type: MealType,
        price: Price,
        next_served: Date,
        _allergens: Vec<Allergen>,
        _additives: Vec<Additive>,
    ) -> Result<Meal> {
        let meal = Meal {
            name,
            meal_type,
            price,
            next_served: Some(next_served),
            ..get_meal()
        };
        Ok(meal)
    }
    /// Adds a new side entity to the database. Returns the new entity.
    async fn insert_side(
        &self,
        name: String,
        meal_type: MealType,
        price: Price,
        _next_served: Date,
        _allergens: Vec<Allergen>,
        _additives: Vec<Additive>,
    ) -> Result<Side> {
        let side = Side {
            name,
            meal_type,
            price,
            ..get_side()
        };
        Ok(side)
    }
}