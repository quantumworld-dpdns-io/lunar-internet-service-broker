use thiserror::Error;

#[derive(Error, Debug)]
pub enum LunarError {
    #[error("validation error: {0}")]
    Validation(String),

    #[error("not found: {0}")]
    NotFound(String),

    #[error("matching error: {0}")]
    MatchingError(String),

    #[error("blockchain error: {0}")]
    BlockchainError(String),

    #[error("crypto error: {0}")]
    CryptoError(String),

    #[error("storage error: {0}")]
    StorageError(String),

    #[error("serialization error: {0}")]
    Serialization(String),
}
