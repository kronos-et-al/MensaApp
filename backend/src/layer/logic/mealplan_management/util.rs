use tracing::{debug, info, trace, warn};
use crate::interface::persistent_data::DataError;

pub fn trace_canteen_resolved(name: &String) {
    debug!("resolved canteen '{name}' with no errors");
}

pub fn error_canteen_resolved(name: &String, error: &DataError) {
    warn!("resolved canteen '{name}' with errors: {error}");
}