use lunar_core::error::LunarError;
use lunar_core::traits::{BlockchainConnector, Event};
use lunar_core::types::MatchResult;

pub struct EVMConnector {
    rpc_url: String,
    chain_id: u64,
}

impl EVMConnector {
    pub fn new(rpc_url: &str, chain_id: u64) -> Self {
        Self {
            rpc_url: rpc_url.to_string(),
            chain_id,
        }
    }
}

#[async_trait::async_trait]
impl BlockchainConnector for EVMConnector {
    async fn submit_commitment(&self, commitment: &MatchResult) -> Result<String, LunarError> {
        // TODO: Implement actual Ethereum transaction
        Ok(format!(
            "0x{}",
            hex::encode(commitment.id.as_bytes())
        ))
    }

    async fn verify_commitment(&self, commitment_id: &str) -> Result<bool, LunarError> {
        // TODO: Implement actual on-chain verification
        Ok(true)
    }

    async fn get_contract_events(&self, from_block: u64) -> Result<Vec<Event>, LunarError> {
        // TODO: Implement event fetching from chain
        Ok(Vec::new())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use lunar_core::traits::BlockchainConnector;
    use lunar_core::types::*;
    use chrono::Utc;
    use uuid::Uuid;

    #[tokio::test]
    async fn test_submit_commitment() {
        let connector = EVMConnector::new("http://localhost:8545", 31337);
        let commitment = MatchResult {
            id: Uuid::new_v4(),
            offer_id: Uuid::new_v4(),
            request_id: Uuid::new_v4(),
            score: 0.95,
            allocated_bandwidth_mbps: 100.0,
            total_price: 50.0,
            schedule_from: Utc::now(),
            schedule_until: Utc::now(),
            status: MatchStatus::Pending,
        };
        let result = connector.submit_commitment(&commitment).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_verify_commitment() {
        let connector = EVMConnector::new("http://localhost:8545", 31337);
        let result = connector.verify_commitment("test-id").await;
        assert!(result.is_ok());
        assert!(result.unwrap());
    }
}
