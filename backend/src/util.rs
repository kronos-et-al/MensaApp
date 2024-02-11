//! This package contains structures that are used in many components.
//!
//! For a complete list and explanations you can see [here](https://www.sw-ka.de/media/?file=4458listeallergesetzlichausweisungspflichtigenzusatzstoffeundallergenefuerwebsite160218.pdf&download).

use std::fmt::Display;

use async_graphql::Enum;
use image::DynamicImage;
use lazy_static::lazy_static;

/// Date type used in multiple places.
pub type Date = chrono::NaiveDate;

/// Uuid type used in multiple places.
pub type Uuid = uuid::Uuid;

/// An in memory representation of an image containing pixels.
pub type ImageResource = DynamicImage;

/// File extension used for images
pub const IMAGE_EXTENSION: &str = "jpg";

/// Base path under which images can be accessed.
pub const IMAGE_BASE_PATH: &str = "/image";

/// This enum lists every possible allergen a meal can have.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum, sqlx::Type)]
#[sqlx(type_name = "allergen", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Allergen {
    /// This meal contains cashews.
    Ca,
    /// This meal contains spelt and gluten.
    Di,
    /// This meal contains eggs.
    Ei,
    /// This meal contains peanuts.
    Er,
    /// This meal contains fish.
    Fi,
    /// This meal contains barley and barley gluten.
    Ge,
    /// This meal contains oat and oat gluten.
    Hf,
    /// This meal contains hazelnuts.
    Ha,
    /// This meal contains kamut and kamut gluten.
    Ka,
    /// This meal contains crustaceans.
    Kr,
    /// This meal contains lupin.
    Lu,
    /// This meal contains almonds.
    Ma,
    /// This meal contains milk / lactose.
    ML,
    /// This meal contains brazil nuts.
    Pa,
    /// This meal contains pecans.
    Pe,
    /// This meal contains pistachios.
    Pi,
    /// This meal contains macadamia nuts.
    Qu,
    /// This meal contains rye and rye gluten.
    Ro,
    /// This meal contains sesame.
    Sa,
    /// This meal contains celery.
    Se,
    /// This meal contains sulphite.
    Sf,
    /// This meal contains mustard.
    Sn,
    /// This meal contains soya.
    So,
    /// This meal contains walnuts.
    Wa,
    /// This meal contains wheat and wheat gluten.
    We,
    /// This meal contains molluscs.
    Wt,
    /// This meal contains animal rennet.
    La,
    /// This meal contains gelatin.
    Gl,
}

/// This enum lists every possible additive a meal can have.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum, sqlx::Type)]
#[sqlx(type_name = "additive", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum Additive {
    /// This meal contains colorants.
    Colorant,
    /// This meal contains preserving agents.
    PreservingAgents,
    /// This meal contains antioxidant agents.
    AntioxidantAgents,
    /// This meal contains flavour enhancers.
    FlavourEnhancer,
    /// This meal contains phosphate.
    Phosphate,
    /// This meals surface is waxed.
    SurfaceWaxed,
    /// This meals contains sulphir.
    Sulphur,
    /// This meals contains artificially blackened olives.
    ArtificiallyBlackenedOlives,
    /// This meals contains sweetener.
    Sweetener,
    /// This meals can be laxative if overused.
    LaxativeIfOverused,
    /// This meals contains phenylalanine.
    Phenylalanine,
    /// This meals can contain alcohol.
    Alcohol,
    /// This meals contains pressed meat.
    PressedMeat,
    /// This meals is glazed with cacao.
    GlazingWithCacao,
    /// This meals contains pressed fish.
    PressedFish,
}

/// This enum lists all the types a meal can be of.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum, sqlx::Type)]
#[sqlx(type_name = "food_type", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum FoodType {
    /// This meal is vegan.
    Vegan,
    /// This meal is vegetarian.
    Vegetarian,
    /// This meal contains beef.
    Beef,
    /// This meal contains beef from regional appropriate animal husbandry.
    BeefAw,
    /// This meal contains pork.
    Pork,
    /// This meal contains pork from regional appropriate animal husbandry.
    PorkAw,
    /// This meal contains fish.
    Fish,
    /// It is unknown whether this meal contains any meat or not.
    Unknown,
}

/// This enum lists all the predetermined reasons a image can be reported for.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum, sqlx::Type)]
#[sqlx(type_name = "report_reason", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ReportReason {
    /// This picture shows offensive content.
    Offensive,
    /// This picture is an advert.
    Advert,
    /// This picture does not show a meal.
    NoMeal,
    /// This picture shows the wrong meal.
    WrongMeal,
    /// This picture violates my rights.
    ViolatesRights,
    /// This picture should be removed for some other reason.
    Other,
}

impl Display for ReportReason {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{self:?}")
    }
}

/// This struct contains all price classes. All prices are listed in euro.
#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub struct Price {
    /// Price of the dish for students.
    pub price_student: u32,
    /// Price of the dish for employees.
    pub price_employee: u32,
    /// Price of the dish for guests.
    pub price_guest: u32,
    /// Price of the dish for pupils.
    pub price_pupil: u32,
}

lazy_static! {
    static ref BASE_URL: String = std::env::var("BASE_URL").unwrap_or_else(|_| "localhost".into());
}

/// Prepends the servers domain to get a global url. Slug should start with a `/`.
#[must_use]
pub fn local_to_global_url(slug: &str) -> String {
    format!("{}{slug}", BASE_URL.as_str())
}

/// Returns the url an image will be accessible given its id.
#[must_use]
pub fn image_id_to_url(id: Uuid) -> String {
    local_to_global_url(&format!("{IMAGE_BASE_PATH}/{id}.{IMAGE_EXTENSION}"))
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use super::*;

    #[test]
    fn test_global_url() {
        assert_eq!(
            format!("{}/myslug", BASE_URL.as_str()),
            local_to_global_url("/myslug")
        );
    }

    #[test]
    fn test_image_to_url() {
        let uuid = Uuid::from_str("3945b556-2f02-427e-83be-46c0aa1a5cc9").expect("valid uuid");
        assert_eq!(
            format!(
                "{}{IMAGE_BASE_PATH}/{uuid}.{IMAGE_EXTENSION}",
                BASE_URL.as_str()
            ),
            image_id_to_url(uuid)
        );
    }
}
