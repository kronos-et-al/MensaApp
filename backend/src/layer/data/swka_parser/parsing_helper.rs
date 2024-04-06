//! This module contains some helper functions for parsing parts of the meal plan.
use crate::util::{Additive, Allergen, FoodType};

impl Allergen {
    /// Parses an allergen from its representation in the meal plan.
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

impl Additive {
    /// Parses an additive from its representation in the meal plan.
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

impl FoodType {
    /// Parses a meal's type from its representation in the meal plan.
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
