use tracing::trace;
use crate::interface::persistent_data::DataError;

pub fn trace_canteen_resolved(name: &String) {
    trace!("resolved canteen '{name}' with no errors");
}

pub fn error_canteen_resolved(name: &String, error: &DataError) {
    panic!("resolved canteen '{name}' with errors: {error}");
}