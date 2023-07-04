use async_graphql::{SimpleObject};


#[derive(SimpleObject, Debug)]
pub struct Price {
    /// The price of the meal for students
    pub student: u32,
    /// The price of the meal for employees
    pub employee: u32,
    /// The price of the meal for guests
    pub guest: u32,
    /// The price of the meal for pupils
    pub pupil: u32,
}