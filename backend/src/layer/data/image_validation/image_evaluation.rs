use crate::interface::image_validation::ImageValidationError::InvalidContent;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::SafeSearchJson;

/// The [`ImageEvaluation`] struct is used to verify and validate the
/// evaluated results of the [`ApiRequest`] class.
pub struct ImageEvaluation {
    acceptance: [u8; 5],
}

impl ImageEvaluation {
    /// This method creates a new instance of the [`ImageEvaluation`] struct
    /// # Params
    /// `acceptance`<br>
    /// The acceptance array contains all allowed value levels
    /// of the five **safe-search categories** in the following order:<br>
    /// `adult`, `spoof`, `medical`, `violence` and `racy`.<br>
    /// There are five different `levels` for each category:
    /// `VERY_UNLIKELY`=1, `UNLIKELY`=2, `POSSIBLE`=3, `LIKELY`=4 and `VERY_LIKELY`=5.
    /// #### Example
    /// If we want to block only adult content, the following acceptance array is the right joice:<br>
    /// `[1,5,5,5,5]`<br>
    /// Now the first category (adult) has a maximum level of 1, which means every input that is
    /// greater than 1 will not be accepted. All other categories are at the maximum level,
    /// which means every level is accepted.
    #[must_use]
    pub const fn new(acceptance: [u8; 5]) -> Self {
        Self { acceptance }
    }

    /// This method checks if the input values are allowed with the max level configuration for each category.
    /// that is set in the relation [`ImageEvaluation`] struct.
    /// For more information about levels and categories see [`ImageEvaluation::new`].
    /// # Params
    /// `value_json`<br>
    /// This param contains all the evaluated levels for each category.
    /// # Errors
    /// This method returns an error if the proved results do not match with the configuration.
    /// The error message contains the failing category.
    /// # Return
    /// Nothing if the values match with the configuration.
    pub fn verify(&self, value_json: &SafeSearchJson) -> Result<()> {
        let values = result_to_arr(value_json);
        for (i, value) in values.iter().enumerate() {
            if value > &self.acceptance[i] {
                return Err(InvalidContent(format!(
                    "This image contains probably {} content",
                    type_determination(i)
                )));
            }
        }
        Ok(())
    }
}

fn result_to_arr(results: &SafeSearchJson) -> [u8; 5] {
    [
        map(&results.adult),
        map(&results.spoof),
        map(&results.medical),
        map(&results.violence),
        map(&results.racy),
    ]
}

fn map(level: &str) -> u8 {
    match level {
        "UNKNOWN" => 0,
        "VERY_UNLIKELY" => 1,
        "UNLIKELY" => 2,
        "POSSIBLE" => 3,
        "LIKELY" => 4,
        "VERY_LIKELY" => 5,
        _ => 42,
    }
}

fn type_determination(level: usize) -> String {
    match level {
        0 => String::from("adult"),
        1 => String::from("spoof"),
        2 => String::from("medical"),
        3 => String::from("violent"),
        4 => String::from("racy"),
        _ => String::from("unknown"),
    }
}
