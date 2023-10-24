#![allow(non_snake_case)]
use serde::Deserialize;

/// Example for a valid `safeSearch` response structure:
/// ```json
///{
///   "responses": [
///     {
///       "safeSearchAnnotation": {
///         "adult": "UNLIKELY",
///         "spoof": "VERY_UNLIKELY",
///         "medical": "VERY_UNLIKELY",
///         "violence": "LIKELY",
///         "racy": "POSSIBLE"
///       }
///     }
///   ]
/// }
/// ```
#[derive(Debug, Deserialize, Copy)]
pub struct SafeSearchResponseJson {
    /// See [`SafeSearchResponseJson`]
    pub responses: Vec<ResponseJson>,
}

/// See [`SafeSearchResponseJson`]
#[derive(Debug, Deserialize, Copy)]
pub struct ResponseJson {
    /// See [`SafeSearchResponseJson`]
    pub safeSearchAnnotation: SafeSearchJson,
}

/// See [`SafeSearchResponseJson`]
#[derive(Debug, Deserialize, Copy)]
pub struct SafeSearchJson {
    /// See [`SafeSearchResponseJson`]
    pub adult: String,
    /// See [`SafeSearchResponseJson`]
    pub spoof: String,
    /// See [`SafeSearchResponseJson`]
    pub medical: String,
    /// See [`SafeSearchResponseJson`]
    pub violence: String,
    /// See [`SafeSearchResponseJson`]
    pub racy: String,
}
