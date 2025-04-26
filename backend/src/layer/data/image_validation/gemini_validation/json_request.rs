#![allow(non_snake_case)]
use serde::Deserialize;

/// Example for a valid `gemini` response structure:
/// ```json
///{
///   "candidates": [
///     {
///       "content": {
///         "parts": [
///             {
///                 "text":"Nein. Auf dem Bild ist eine Person zu sehen."
///             }
///         ]
///       }
///     }
///   ]
/// }
/// ```
#[derive(Debug, Deserialize)]
pub struct GeminiResponseJson {
    pub(crate) candidates: Vec<ResponseJson>,
}
/// See [`GeminiResponseJson`]
#[derive(Debug, Deserialize)]
pub struct ResponseJson {
    pub(crate) content: PartJson,
}
/// See [`GeminiResponseJson`]
#[derive(Debug, Deserialize)]
pub struct PartJson {
    pub(crate) parts: Vec<MessageJson>,
}
/// See [`GeminiResponseJson`]
#[derive(Debug, Deserialize)]
pub struct MessageJson {
    pub(crate) text: String,
}
