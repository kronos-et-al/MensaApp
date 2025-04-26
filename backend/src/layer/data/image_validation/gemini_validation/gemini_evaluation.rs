use tracing_subscriber::fmt::format;
use crate::interface::image_validation::ImageValidationError::{ImageInvalid, InvalidResponse};
use crate::interface::image_validation::Result;

const ACCEPT_KEYWORD: &str = "Yes";
const REJECT_KEYWORD: &str = "No";

#[derive(Default)]
pub struct GeminiEvaluation {}

impl GeminiEvaluation {
    pub fn evaluate(&self, text_response: String) -> Result<()> {
        if text_response.contains(ACCEPT_KEYWORD) {
            Ok(())
        } else if text_response.contains(REJECT_KEYWORD) {
            Err(ImageInvalid(filter_invalid_reason(text_response)))
        } else {
            Err(InvalidResponse)
        }
    }
}

fn filter_invalid_reason(text: String) -> String {
    text.replace(&format!("{REJECT_KEYWORD}."), "").replace(&format!("{REJECT_KEYWORD},"), "").replace(REJECT_KEYWORD, "").trim().to_string()
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]

    use crate::layer::data::image_validation::gemini_validation::gemini_evaluation::filter_invalid_reason;

    #[test]
    fn test_filter_invalid_reason() {
        let test_s1 = "No. Unacceptable.".to_string();
        let res_s1 = "Unacceptable.".to_string();
        let test_s2 = "No, as we know!".to_string();
        let res_s2 = "as we know!".to_string();
        let test_s3 = "No".to_string();
        let res_s3 = String::new();
        let test_s4 = "  No.  ".to_string();
        let res_s4 = String::new();
        let test_s5 = "No I don't like this.".to_string();
        let res_s5 = "I don't like this.".to_string();
        assert_eq!(filter_invalid_reason(test_s1), res_s1);
        assert_eq!(filter_invalid_reason(test_s2), res_s2);
        assert_eq!(filter_invalid_reason(test_s3), res_s3);
        assert_eq!(filter_invalid_reason(test_s4), res_s4);
        assert_eq!(filter_invalid_reason(test_s5), res_s5);
    }
}
