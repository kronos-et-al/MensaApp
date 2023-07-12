#[derive(Copy, Clone)]
pub enum ImageCommandType {
    ReportImage,
    AddUpvote,
    AddDownvote,
    RemoveUpvote,
    RemoveDownvote,
}

impl ToString for ImageCommandType {
    fn to_string(&self) -> String {
        match self {
            Self::ReportImage => "reportImage",
            Self::AddUpvote => "addUpvote",
            Self::AddDownvote => "addDownvote",
            Self::RemoveUpvote => "removeUpvote",
            Self::RemoveDownvote => "removeDownvote",
        }
        .into()
    }
}
