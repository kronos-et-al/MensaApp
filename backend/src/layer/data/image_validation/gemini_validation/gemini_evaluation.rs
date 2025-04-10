use crate::interface::image_validation::ImageValidationError::{ImageInvalid, InvalidResponse};
use crate::interface::image_validation::Result;

#[derive(Default)]
pub struct GeminiEvaluation { }


impl GeminiEvaluation {
    pub fn evaluate(&self, text_response: String) -> Result<()> {
        match text_response.contains("Ja") {
            true => Ok(()),
            false => {
                match text_response.contains("Nein") {
                    true => Err(ImageInvalid(filter_invalid_reason(text_response))),
                    false => Err(InvalidResponse),
                }
            }
        }
    }
}

fn filter_invalid_reason(text: String) -> String {
    let mut reason = text.replace("Nein.", "");
    reason = reason.replace("Nein,", "");
    reason.replace("Nein", "").trim().to_string()
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use crate::layer::data::image_validation::gemini_validation::gemini_evaluation::filter_invalid_reason;

    #[test]
    fn test_filter_invalid_reason() {
        let test_s1 = "Nein. Das stimmt nicht.".to_string();
        let res_s1 = "Das stimmt nicht.".to_string();
        let test_s2 = "Nein, wie wir wissen!".to_string();
        let res_s2 = "wie wir wissen!".to_string();
        let test_s3 = "Nein".to_string();
        let res_s3 = "".to_string();
        let test_s4 = "  Nein.  ".to_string();
        let res_s4 = "".to_string();
        let test_s5 = "Nein dass gefällt mir nicht.".to_string();
        let res_s5 = "das gefällt mir nicht.".to_string();
        assert_eq!(filter_invalid_reason(test_s1), res_s1);
        assert_eq!(filter_invalid_reason(test_s2), res_s2);
        assert_eq!(filter_invalid_reason(test_s3), res_s3);
        assert_eq!(filter_invalid_reason(test_s4), res_s4);
        assert_eq!(filter_invalid_reason(test_s5), res_s5);
    }
}