//! This package contains structures that are used in many components.
//!
//! For a complete list and explanations you can see [here](https://www.sw-ka.de/media/?file=4458listeallergesetzlichausweisungspflichtigenzusatzstoffeundallergenefuerwebsite160218.pdf&download).

use std::{fmt::Display};

use async_graphql::Enum;

/// Date type used in multiple places.
pub type Date = chrono::NaiveDate;

// Uuid type used in multiple places.
pub type Uuid = uuid::Uuid;

/// This enum lists every possible allergen a meal can have.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum)]
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

impl Display for Allergen {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.value())
    }
}

impl Allergen {
    const fn value(&self) -> &str {
        match self {
            Self::Ca => "Cashews",
            Self::Di => "Spelt and spelt gluten",
            Self::Ei => "Eggs",
            Self::Er => "Peanuts",
            Self::Fi => "Fish",
            Self::Ge => "Barley and barley gluten",
            Self::Hf => "Oat and oat gluten",
            Self::Ha => "Hazelnuts",
            Self::Ka => "Kamut and kamut gluten",
            Self::Kr => "Crustaceans",
            Self::Lu => "Lupin",
            Self::Ma => "Almonds",
            Self::ML => "Milk/lactose",
            Self::Pa => "Brazil nuts",
            Self::Pe => "Pecans",
            Self::Pi => "Pistachios",
            Self::Qu => "Macadamia nuts",
            Self::Ro => "Rye and rye gluten",
            Self::Sa => "Sesame",
            Self::Se => "Celery",
            Self::Sf => "Sulphite",
            Self::Sn => "Mustard",
            Self::So => "Soy",
            Self::Wa => "Walnuts",
            Self::We => "Wheat and wheat gluten",
            Self::Wt => "Molluscs",
            Self::La => "With animal loaf",
            Self::Gl => "With gelatine",
            _ => "",
        }
    }


    #[must_use]
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "Ca" => Some(Self::Ca),
            "Di" => Some(Self::Di),
            "Ei" => Some(Self::Ei),
            "Er" => Some(Self::Er),
            "Fi" => Some(Self::Fi),
            "Ge" => Some(Self::Ge),
            "Hf" => Some(Self::Hf),
            "Ha" => Some(Self::Ha),
            "Ka" => Some(Self::Ka),
            "Kr" => Some(Self::Kr),
            "Lu" => Some(Self::Lu),
            "Ma" => Some(Self::Ma),
            "ML" => Some(Self::ML),
            "Pa" => Some(Self::Pa),
            "Pe" => Some(Self::Pe),
            "Pi" => Some(Self::Pi),
            "Qu" => Some(Self::Qu),
            "Ro" => Some(Self::Ro),
            "Sa" => Some(Self::Sa),
            "Se" => Some(Self::Se),
            "Sf" => Some(Self::Sf),
            "Sn" => Some(Self::Sn),
            "So" => Some(Self::So),
            "Wa" => Some(Self::Wa),
            "We" => Some(Self::We),
            "Wt" => Some(Self::Wt),
            "LAB" => Some(Self::La),
            "GL" => Some(Self::Gl),
            _ => None,
        }
    }
}

/// This enum lists every possible additive a meal can have.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum)]
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

impl Display for Additive {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.value())
    }
}

impl Additive {
    const fn value(&self) -> &str {
        match self {
            Self::Colorant => "Colorant",
            Self::PreservingAgents => "Preserving agents",
            Self::AntioxidantAgents => "Antioxidant agents",
            Self::FlavourEnhancer => "Flavour enhancer",
            Self::Phosphate => "Phosphate",
            Self::SurfaceWaxed => "Surface waxed",
            Self::Sulphur => "Sulphur",
            Self::ArtificiallyBlackenedOlives => "Artificially blackened olives",
            Self::Sweetener => "Sweetener",
            Self::LaxativeIfOverused => "Laxative if overused",
            Self::Phenylalanine => "Phenylalanine",
            Self::Alcohol => "Alcohol",
            Self::PressedMeat => "Pressed meat",
            Self::GlazingWithCacao => "Glazing with cacao",
            Self::PressedFish => "Pressed fish",
            _ => "",
        }
    }

    #[must_use]
    pub fn parse(s: &str) -> Option<Self> {
        match s {
            "1" => Some(Self::Colorant),
            "2" => Some(Self::PreservingAgents),
            "3" => Some(Self::AntioxidantAgents),
            "4" => Some(Self::FlavourEnhancer),
            "5" => Some(Self::Phosphate),
            "6" => Some(Self::SurfaceWaxed),
            "7" => Some(Self::Sulphur),
            "8" => Some(Self::ArtificiallyBlackenedOlives),
            "9" => Some(Self::Sweetener),
            "10" => Some(Self::LaxativeIfOverused),
            "11" => Some(Self::Phenylalanine),
            "12" => Some(Self::Alcohol),
            "14" => Some(Self::PressedMeat),
            "15" => Some(Self::GlazingWithCacao),
            "27" => Some(Self::PressedFish),
            _ => None,
        }
    }
}

/// This enum lists all the types a meal can be of.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum)]
pub enum MealType {
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

impl Display for MealType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.value())
    }
}

impl MealType {
    const fn value(&self) -> &str {
        match self {
            Self::Vegan => "veganes Gericht",
            Self::Vegetarian => "vegetarisches Gericht",
            Self::Beef => "enthält Rindfleisch",
            Self::BeefAw => "enthält regionales Rindfleisch aus artgerechter Tierhaltung",
            Self::Pork => "enthält Schweinefleisch",
            Self::PorkAw => "enthält regionales Schweinefleisch aus artgerechter Tierhaltung",
            Self::Fish => "MSC aus zertifizierter Fischerei",
            _ => "",
        }
    }

    #[must_use]
    pub fn parse(s: &str) -> Self {
        match s {
            "veganes Gericht" => Self::Vegan,
            "vegetarisches Gericht" => Self::Vegetarian,
            "enthält Rindfleisch" => Self::Beef,
            "enthält regionales Rindfleisch aus artgerechter Tierhaltung" => Self::BeefAw,
            "enthält Schweinefleisch" => Self::Pork,
            "enthält regionales Schweinefleisch aus artgerechter Tierhaltung" => Self::PorkAw,
            "MSC aus zertifizierter Fischerei" => Self::Fish,
            _ => Self::Unknown,
        }
    }
}

/// This enum lists all the predetermined reasons a image can be reported for.
#[derive(Debug, Copy, Clone, Eq, PartialEq, Enum)]
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

/// This struct contains all price classes. All prices are listed in euro.
#[derive(Debug)]
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

impl Display for Price {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Prices: Student: {}, Employee: {}, Guest: {}, Pupil: {}",
            self.price_student, self.price_employee, self.price_guest, self.price_pupil
        )
    }
}
