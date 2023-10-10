use crate::interface::image_validation::Result;

//todo
pub struct ImageEvaluation {
    acceptance: [u8; 5],
}

impl ImageEvaluation {
    //todo
    pub const fn new(acceptance: [u8; 5]) -> Self {
        Self { acceptance }
    }

    //todo
    pub fn verify() -> Result<()> {
        todo!()
    }
}
