use async_graphql::Context;

use crate::{
    interface::{
        api_command::{AuthInfo, Command},
        persistent_data::RequestDataAccess,
    },
    util::Uuid,
};

pub type DataBox = Box<dyn RequestDataAccess + Sync + Send + 'static>;
pub type CommandBox = Box<dyn Command + Sync + Send + 'static>;

pub trait ApiUtil {
    fn get_command(&self) -> &(dyn Command + Sync + Send);
    fn get_data_access(&self) -> &(dyn RequestDataAccess + Sync + Send);
    fn get_auth_info(&self) -> AuthInfo;
}

impl<'a> ApiUtil for Context<'a> {
    fn get_command(&self) -> &'a (dyn Command + Sync + Send) {
        self.data_unchecked::<CommandBox>().as_ref()
    }

    fn get_data_access(&self) -> &'a (dyn RequestDataAccess + Sync + Send) {
        self.data_unchecked::<DataBox>().as_ref()
    }

    fn get_auth_info(&self) -> AuthInfo {
        AuthInfo {
            client_id: Uuid::new_v4(),
            api_ident: "()".into(),
            hash: "()".into(),
        }
    }
}
