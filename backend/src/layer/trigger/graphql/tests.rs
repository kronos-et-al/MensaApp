#![cfg(test)]
#![allow(clippy::unwrap_used)]

use async_graphql::{EmptySubscription, Schema};

use crate::layer::trigger::graphql::mutation::MutationRoot;
use crate::layer::trigger::graphql::query::QueryRoot;
use crate::layer::trigger::graphql::util::{CommandBox, DataBox};

use super::mock::{CommandMock, RequestDatabaseMock};

#[tokio::test]
async fn test_query() {
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(Box::new(RequestDatabaseMock) as DataBox)
        .data(Box::new(CommandMock) as CommandBox)
        .finish();

    let request_string = r#"
mutation {
    addImage(mealId:"1d75d380-cf07-4edb-9046-a2d981bc219d", imageUrl:"")
}    
    "#;

    let result = schema.execute(request_string).await;
    // TODO
    // assert!(result.is_ok(), "assert failed: {:?}", result.errors);
    // assert_eq!("", result.data.to_string());
}
