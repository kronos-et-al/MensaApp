use heck::AsShoutySnakeCase;

use crate::util::{Additive, Allergen};

impl Allergen {
    #[must_use]
    pub fn to_db_string(self) -> String {
        format!("{}", AsShoutySnakeCase(format!("{self:?}")))
    }
}

impl Additive {
    #[must_use]
    pub fn to_db_string(self) -> String {
        format!("{}", AsShoutySnakeCase(format!("{self:?}")))
    }
}
