//! See [`google_api_handler`]

/// This module is used to verify and validate the evaluated results of the request classes.
pub mod gemini_validation;
/// This module is used to manage tasks of this component.
pub mod google_api_handler;
/// This module is used to send images and requests safe-search results from the api rest interface.
pub mod safe_search_validation;
