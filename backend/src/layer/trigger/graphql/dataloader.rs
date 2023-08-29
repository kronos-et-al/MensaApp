use std::collections::HashMap;

use async_trait::async_trait;

use crate::{util::Uuid, interface::persistent_data::{DataError, RequestDataAccess, model::Canteen}};


use async_graphql::dataloader::Loader;



pub struct CanteenDataLoader {
    data: Box<dyn RequestDataAccess>
}

impl CanteenDataLoader {
    pub fn new(data: impl RequestDataAccess + 'static) -> Self {
        Self {
            data: Box::new(data),
        }
    }
}

// little bit useless here... maybe useful fore cashing
#[async_trait]
impl Loader<()> for CanteenDataLoader {
    type Value = Vec<Canteen>;
    type Error = DataError;

    async fn load(&self, _keys: &[()]) -> Result<HashMap<(), Self::Value>, Self::Error> {
        self.data.get_canteens().await.map(|c| HashMap::from([((), c)]))
    }

    
}

#[async_trait]
impl Loader<Uuid> for CanteenDataLoader {
    type Value = Option<Canteen>;
    type Error = DataError;

    async fn load(&self, keys: &[Uuid]) -> Result<HashMap<Uuid, Self::Value>, Self::Error> {
        self.data.get_canteen_multi(keys).await
    }

    
}