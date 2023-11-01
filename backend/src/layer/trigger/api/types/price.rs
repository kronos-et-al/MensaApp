use async_graphql::SimpleObject;

#[derive(SimpleObject, Debug)]
pub(in super::super) struct Price {
    /// The price of the meal for students.
    pub(in super::super) student: u32,
    /// The price of the meal for employees.
    pub(in super::super) employee: u32,
    /// The price of the meal for guests.
    pub(in super::super) guest: u32,
    /// The price of the meal for pupils.
    pub(in super::super) pupil: u32,
}
