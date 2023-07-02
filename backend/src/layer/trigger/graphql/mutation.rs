use async_graphql::{Context, Object, Result};

use crate::util::Uuid;

use super::util::ApiUtil;

/// Class implementing `GraphQLs` root mutations.
pub struct MutationRoot;

#[Object]
impl MutationRoot {
    /// This query adds an image to the specified main dish.
    ///
    /// The link used is the Flickr link of the image is used as a link,
    /// which can be used to retrieve and save the data and saved in the backend of Flickr.
    /// If the dish does not exist, or the link does not lead to Flickr
    /// or the license of the image is not "Creative Commons"
    /// or another error occurred while adding the image an error message will be returned.
    /// If the image was added is successful, a true value is returned.
    async fn add_image(
        &self,
        ctx: &Context<'_>,
        #[graphql(desc = "Id of object")] meal_id: Uuid,
        #[graphql(desc = "Id of object")] image_url: String,
    ) -> Result<bool> {
        let command = ctx.get_command();
        let auth_info = ctx.get_auth_info();

        command.add_image(meal_id, image_url, auth_info).await?;
        Ok(true)
    }
}
