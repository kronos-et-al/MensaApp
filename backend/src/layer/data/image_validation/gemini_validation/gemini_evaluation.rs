use crate::interface::image_validation::ImageValidationError::{
    GeminiPhraseDecodeFailed, GeminiRejectionError,
};
use crate::interface::image_validation::Result;

const ACCEPT_KEYWORD: &str = "Yes";
const REJECT_KEYWORD: &str = "No";

/// The [`GeminiEvaluation`] struct is used to evaluate the gemini response.
#[derive(Default)]
pub struct GeminiEvaluation {}

impl GeminiEvaluation {
    /// This method evaluates the provided text provided by the gemini api.
    /// # Params
    /// `text_response`<br>
    /// This param contains all the mentioned response.
    /// # Errors
    /// This method returns an error if the evaluation decides to deny the image or the response could not be determined.
    /// # Return
    /// Nothing, what means the evaluation decided to accept the image.
    pub fn evaluate(&self, text_response: &str) -> Result<String> {
        if text_response.contains(ACCEPT_KEYWORD) {
            Ok(filter_reason(text_response))
        } else if text_response.starts_with(REJECT_KEYWORD) {
            Err(GeminiRejectionError(filter_reason(text_response)))
        } else {
            Err(GeminiPhraseDecodeFailed(text_response.to_string()))
        }
    }
}

fn filter_reason(text: &str) -> String {
    text.replace(&format!("{REJECT_KEYWORD}."), "")
        .replace(&format!("{REJECT_KEYWORD},"), "")
        .replace(&format!("{ACCEPT_KEYWORD},"), "")
        .replace(&format!("{ACCEPT_KEYWORD}."), "")
        .replace(ACCEPT_KEYWORD, "")
        .replace(REJECT_KEYWORD, "")
        .trim()
        .to_string()
}

#[cfg(test)]
mod tests {
    #![allow(clippy::unwrap_used)]
    use crate::layer::data::image_validation::gemini_validation::gemini_evaluation::{
        filter_reason, GeminiEvaluation,
    };

    #[test]
    fn test_evaluate() {
        assert!(GeminiEvaluation::default()
            .evaluate("Yes, this image shows potatoes.")
            .is_ok());
        assert!(GeminiEvaluation::default().evaluate("Yes").is_ok());
        assert!(GeminiEvaluation::default().evaluate("").is_err());
        assert!(GeminiEvaluation::default().evaluate("No.").is_err());
        assert!(GeminiEvaluation::default()
            .evaluate("No, there is no meal visible.")
            .is_err());
    }

    #[test]
    fn test_filter_invalid_reason() {
        assert_eq!(
            filter_reason("No. Unacceptable."),
            String::from("Unacceptable.")
        );
        assert_eq!(
            filter_reason("No, as we know!"),
            String::from("as we know!")
        );
        assert_eq!(filter_reason("No"), String::new());
        assert_eq!(filter_reason("  No.  "), String::new());
        assert_eq!(
            filter_reason("No I don't like this."),
            String::from("I don't like this.")
        );
    }
}
