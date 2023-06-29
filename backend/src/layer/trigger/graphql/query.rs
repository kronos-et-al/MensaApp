use async_graphql::Object;

/// Class implementing GraphQLs root queries.
pub struct QueryRoot;


#[Object]
impl QueryRoot {
    async fn test(&self) -> bool {
        true
    }
}
