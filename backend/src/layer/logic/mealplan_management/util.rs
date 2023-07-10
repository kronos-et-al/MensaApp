use tracing::trace;

pub fn trace_canteen_resolved(name: &String) {
    trace!("resolved canteen {} with no errors", name)
}

pub fn error_canteen_resolved(error: &String) {
    panic!("resolved canteen {} with errors:", error)
}