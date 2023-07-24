use std::num::TryFromIntError;

use heck::AsSnakeCase;

use crate::util::{Allergen, Price, Additive};

#[derive(Debug, sqlx::Type)]
#[sqlx(type_name = "prices")]
pub struct DatabasePrice {
    /// Price of the dish for students.
    pub student: i32,
    /// Price of the dish for employees.
    pub employee: i32,
    /// Price of the dish for guests.
    pub guest: i32,
    /// Price of the dish for pupils.
    pub pupil: i32,
}

impl TryFrom<DatabasePrice> for Price {
    type Error = TryFromIntError;

    fn try_from(value: DatabasePrice) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            price_student: value.student.try_into()?,
            price_employee: value.employee.try_into()?,
            price_guest: value.guest.try_into()?,
            price_pupil: value.pupil.try_into()?,
        })
    }
}

impl TryFrom<Price> for DatabasePrice {
    type Error = TryFromIntError;

    fn try_from(value: Price) -> std::result::Result<Self, Self::Error> {
        Ok(Self {
            student: value.price_student.try_into()?,
            employee: value.price_employee.try_into()?,
            guest: value.price_guest.try_into()?,
            pupil: value.price_pupil.try_into()?,
        })
    }
}

impl Allergen {
    pub fn to_db_string(self) -> String {
        format!("{}", AsSnakeCase(format!("{self:?}")))
    }
}

impl Additive {
    pub fn to_db_string(self) -> String {
        format!("{}", AsSnakeCase(format!("{self:?}")))
    }
}
