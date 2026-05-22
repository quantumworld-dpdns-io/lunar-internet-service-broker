use crate::error::LunarError;
use crate::types::*;
use async_trait::async_trait;

#[async_trait]
pub trait MatchingEngine: Send + Sync {
    async fn find_matches(
        &self,
        request: &RelayRequest,
        offers: &[CapacityOffer],
    ) -> Result<Vec<MatchResult>, LunarError>;

    async fn score_match(
        &self,
        request: &RelayRequest,
        offer: &CapacityOffer,
    ) -> Result<f64, LunarError>;
}

#[async_trait]
pub trait BlockchainConnector: Send + Sync {
    async fn submit_commitment(&self, commitment: &MatchResult) -> Result<String, LunarError>;
    async fn verify_commitment(&self, commitment_id: &str) -> Result<bool, LunarError>;
    async fn get_contract_events(&self, from_block: u64) -> Result<Vec<Event>, LunarError>;
}

#[derive(Debug, Clone)]
pub struct Event {
    pub name: String,
    pub block_number: u64,
    pub tx_hash: String,
    pub data: serde_json::Value,
}
