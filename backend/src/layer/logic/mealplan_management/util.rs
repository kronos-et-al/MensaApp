use tracing::trace;
use crate::interface::persistent_data::DataError;

pub fn trace_canteen_resolved(name: &String) {
    trace!("resolved canteen '{}' with no errors", name)
}

pub fn error_canteen_resolved(name: &String, error: DataError) {
    panic!("resolved canteen '{name}' with errors: {error}", name = name, error = error.to_string())
}