use heck::AsShoutySnakeCase;

use crate::util::{Additive, Allergen};

impl Allergen {
    /// Converts this instance into its database string representation.
    #[must_use]
    pub fn to_db_string(self) -> String {
        format!("{}", AsShoutySnakeCase(format!("{self:?}")))
    }
}

impl Additive {
    /// Converts this instance into its database string representation.
    #[must_use]
    pub fn to_db_string(self) -> String {
        format!("{}", AsShoutySnakeCase(format!("{self:?}")))
    }
}
