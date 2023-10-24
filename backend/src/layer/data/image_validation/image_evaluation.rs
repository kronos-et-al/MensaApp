use crate::interface::image_validation::ImageValidationError::InvalidContent;
use crate::interface::image_validation::Result;
use crate::layer::data::image_validation::json_structs::SafeSearchJson;

//TODO DOC
pub struct ImageEvaluation {
    acceptance: [u8; 5],
}

impl ImageEvaluation {
    //TODO DOC
    #[must_use]
    pub const fn new(acceptance: [u8; 5]) -> Self {
        Self { acceptance }
    }

    //TODO DOC
    pub fn verify(&self, results: SafeSearchJson) -> Result<()> {
        let values = result_to_arr(&results);
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
