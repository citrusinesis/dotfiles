use thiserror::Error;

#[derive(Debug, Error)]
pub(crate) enum AppError {
    #[error("request setup failed: {0}")]
    Request(#[from] reqwest::Error),
    #[error("response serialization failed: {0}")]
    Serialize(#[from] serde_json::Error),
}
