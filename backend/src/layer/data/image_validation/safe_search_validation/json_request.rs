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
#[derive(Debug, Deserialize)]
pub struct SafeSearchResponseJson {
    pub(crate) responses: Vec<ResponseJson>,
}

/// See [`SafeSearchResponseJson`]
#[derive(Debug, Deserialize)]
pub struct ResponseJson {
    pub(crate) safeSearchAnnotation: SafeSearchJson,
}

/// See [`SafeSearchResponseJson`]
#[derive(Debug, Deserialize)]
pub struct SafeSearchJson {
    pub(crate) adult: String,
    pub(crate) spoof: String,
    pub(crate) medical: String,
    pub(crate) violence: String,
    pub(crate) racy: String,
}
