#![allow(non_snake_case)]
use serde::Deserialize;

/// Example for a valid `safeSearch` response structure:
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
    pub candidates: Vec<ResponseJson>,
}
#[derive(Debug, Deserialize)]
pub struct ResponseJson {
    pub content: PartJson,
}
#[derive(Debug, Deserialize)]
pub struct PartJson {
    pub parts: Vec<MessageJson>,
}
#[derive(Debug, Deserialize)]
pub struct MessageJson {
    pub(crate) text: String,
}
