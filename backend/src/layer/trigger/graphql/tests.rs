#![cfg(test)]
#![allow(clippy::unwrap_used)]

use async_graphql::{EmptySubscription, Schema};

use crate::layer::trigger::graphql::mutation::MutationRoot;
use crate::layer::trigger::graphql::query::QueryRoot;
use crate::layer::trigger::graphql::util::{CommandBox, DataBox};

use super::mock::{CommandMock, RequestDatabaseMock};

async fn test_gql_request(request: &'static str) {
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(Box::new(RequestDatabaseMock) as DataBox)
        .data(Box::new(CommandMock) as CommandBox)
        .finish();
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);
}

#[tokio::test]
async fn test_add_image() {
    let request = r#"
        mutation {
            addImage(mealId:"1d75d380-cf07-4edb-9046-a2d981bc219d", imageUrl:"")
        }    
    "#;
    test_gql_request(request).await;
}
