use std::fmt::Display;

use heck::AsShoutySnakeCase;

use crate::util::{ReportReason, Uuid};

#[derive(Clone)]
/// Enum describing the different types of commands available with each having different parameters that influence hash calculation.
pub enum CommandType {
    /// The command to authenticate is the one for reporting an image with given UUID and reason.
    ReportImage {
        image_id: Uuid,
        reason: ReportReason,
    },
    /// The command to authenticate is the one to add an upvote to the image with given UUID.
    AddUpvote { image_id: Uuid },
    /// The command to authenticate is the one to add a downvote to the image with given UUID.
    AddDownvote { image_id: Uuid },
    /// The command to authenticate is the one to remove an upvote to the image with given UUID.
    RemoveUpvote { image_id: Uuid },
    /// The command to authenticate is the one to remove a downvote to the image with given UUID.
    RemoveDownvote { image_id: Uuid },
    /// The command to authenticate is the one add the given rating to a meal with the given UUID.
    SetRating { meal_id: Uuid, rating: u32 },
    /// The command to authenticate is the one to add an image with the given url to the meal with the given UUID.
    AddImage { meal_id: Uuid, url: String }, // todo adapt
}

impl Display for CommandType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let msg = match self {
            Self::ReportImage { .. } => "reportImage",
            Self::AddUpvote { .. } => "addUpvote",
            Self::AddDownvote { .. } => "addDownvote",
            Self::RemoveUpvote { .. } => "removeUpvote",
            Self::RemoveDownvote { .. } => "removeDownvote",
            Self::SetRating { .. } => "setRating",
            Self::AddImage { .. } => "addImage",
        };
        write!(f, "{msg}")
    }
}

impl CommandType {
    pub(super) fn get_bytes(&self) -> Vec<u8> {
        match self {
            Self::ReportImage { image_id, reason } => {
                [image_id.as_bytes(), reason.to_auth_string().as_bytes()].concat()
            }
            Self::AddUpvote { image_id }
            | Self::AddDownvote { image_id }
            | Self::RemoveUpvote { image_id }
            | Self::RemoveDownvote { image_id } => image_id.as_bytes().to_vec(),
            Self::SetRating { meal_id, rating } => {
                [meal_id.as_bytes(), rating.to_le_bytes().as_ref()].concat()
            }
            Self::AddImage { meal_id, url } => [meal_id.as_bytes(), url.as_bytes()].concat(),
        }
    }
}

impl ReportReason {
    fn to_auth_string(self) -> String {
        format!("{}", AsShoutySnakeCase(format!("{self:?}")))
    }
}
