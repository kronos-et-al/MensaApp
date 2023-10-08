use crate::interface::image_api::Result;

pub struct ImageVerification {
    acceptance: [u8; 5],
}

impl ImageVerification {
    fn new(acceptance: [u8; 5]) -> Self {
        Self { acceptance }
    }

    fn verify() -> Result<()> {
        todo!()
    }
}
