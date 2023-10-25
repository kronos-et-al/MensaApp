//! This component is responsible for image related api operations

/// This module is used to send images and requests safe-search results from the api rest interface.
pub mod api_request;
/// This module is used to manage tasks of this component.
pub mod google_api_handler;
/// This module is used to verify and validate the evaluated results of the [`ApiRequest`] class.
pub mod image_evaluation;
/// This module contains all component related structs that are used to compile or decompile json.
pub mod json_structs;
