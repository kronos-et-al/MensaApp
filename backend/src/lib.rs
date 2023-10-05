#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    unreachable_pub,
    unused_crate_dependencies,
    clippy::pedantic,
    clippy::nursery,
    clippy::unwrap_used,
    clippy::dbg_macro
)]
#![allow(clippy::module_name_repetitions)]
//! # MensaApp-Backend
//! Backend application for providing and synchronizing meal plan data of the canteens of the Studierendenwerk Karlsruhe. [^1]
//! This application is designed with a transparent three layer model in mind.
//!
//! [^1]: <https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/>

pub mod interface;
pub mod layer;
pub mod startup;
pub mod util;

pub use startup::server::Server;
