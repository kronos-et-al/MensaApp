use async_graphql::Object;


/// Class implementing GraphQLs root mutations.
pub struct MutationRoot;


#[Object]
impl MutationRoot {
    /// testty
    async fn test(&self) -> bool {
        true
    }
}