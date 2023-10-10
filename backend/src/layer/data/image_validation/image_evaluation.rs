use crate::interface::image_validation::Result;

pub struct ImageEvaluation {
    acceptance: [u8; 5],
}

impl ImageEvaluation {
    const fn new(acceptance: [u8; 5]) -> Self {
        Self { acceptance }
    }

    fn verify() -> Result<()> {
        todo!()
    }
}
