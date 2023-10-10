#![allow(non_snake_case)]
use serde::Deserialize;

/// Example for a valid `safeSearch` request structure:
/// ```json
///{
///   "requests": [
///     {
///       "image": {
///         "content": "BASE64_ENCODED_IMAGE"
///      },
///       "features": [
///         {
///           "type": "SAFE_SEARCH_DETECTION"
///         },
///       ]
///     }
///   ]
/// }
/// ```

#[derive(Debug, Deserialize)]
pub struct EncodedRequestJson {
    requests: Vec<RequestJson>,
}

#[derive(Debug, Deserialize)]
pub struct RequestJson {
    image: ImageJson,
    features: Vec<FeatureJson>,
}

#[derive(Debug, Deserialize)]
pub struct FeatureJson {
    _type: String, // todo How to set this to just "type"?
}

#[derive(Debug, Deserialize)]
pub struct ImageJson {
    content: String,
}

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
    responses: Vec<ResponseJson>,
}

#[derive(Debug, Deserialize)]
pub struct ResponseJson {
    safeSearchAnnotation: SafeSearchJson,
}

#[derive(Debug, Deserialize)]
pub struct SafeSearchJson {
    adult: String,
    spoof: String,
    medical: String,
    violence: String,
    racy: String,
}
