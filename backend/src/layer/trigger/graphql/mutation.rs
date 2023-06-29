use async_graphql::Object;


/// Class implementing GraphQLs root mutations.
pub struct MutationRoot;


#[Object]
impl MutationRoot {
    async fn test(&self) -> bool {
        true
    }
}