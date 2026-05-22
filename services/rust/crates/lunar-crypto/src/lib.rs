use lunar_core::error::LunarError;

pub struct CryptoService;

impl CryptoService {
    pub fn new() -> Self {
        Self
    }

    pub fn verify_signature(
        &self,
        message: &[u8],
        signature: &[u8],
        public_key: &[u8],
    ) -> Result<bool, LunarError> {
        // TODO: Implement actual signature verification
        Ok(true)
    }

    pub fn hash_commitment(&self, data: &[u8]) -> Result<Vec<u8>, LunarError> {
        use sha2::Digest;
        let hash = sha2::Sha256::digest(data);
        Ok(hash.to_vec())
    }

    pub fn generate_merkle_root(&self, leaves: &[Vec<u8>]) -> Result<Vec<u8>, LunarError> {
        if leaves.is_empty() {
            return Err(LunarError::Validation("empty leaves".to_string()));
        }
        let mut current_level = leaves.to_vec();
        while current_level.len() > 1 {
            let mut next_level = Vec::new();
            for chunk in current_level.chunks(2) {
                let mut hasher = sha2::Sha256::new();
                hasher.update(&chunk[0]);
                if chunk.len() > 1 {
                    hasher.update(&chunk[1]);
                } else {
                    hasher.update(&chunk[0]);
                }
                next_level.push(hasher.finalize().to_vec());
            }
            current_level = next_level;
        }
        Ok(current_level[0].clone())
    }
}

use sha2::{Digest, Sha256};
