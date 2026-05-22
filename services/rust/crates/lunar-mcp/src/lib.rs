// MCP (Model Context Protocol) server for Lunar Internet Service Broker
// Enables AI agents to interact with the broker marketplace

use lunar_core::types::*;
use lunar_matching::BasicMatchingEngine;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Debug, Serialize, Deserialize)]
pub struct MCPRequest {
    pub method: String,
    pub params: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct MCPResponse {
    pub result: serde_json::Value,
    pub error: Option<String>,
}

pub struct MCPBrokerServer {
    matching_engine: Arc<BasicMatchingEngine>,
}

impl MCPBrokerServer {
    pub fn new() -> Self {
        Self {
            matching_engine: Arc::new(BasicMatchingEngine),
        }
    }

    pub fn handle_request(&self, request: MCPRequest) -> MCPResponse {
        match request.method.as_str() {
            "list_offers" => self.handle_list_offers(),
            "list_requests" => self.handle_list_requests(),
            "find_matches" => self.handle_find_matches(request.params),
            "get_market_stats" => self.handle_market_stats(),
            _ => MCPResponse {
                result: serde_json::json!({}),
                error: Some(format!("Unknown method: {}", request.method)),
            },
        }
    }

    fn handle_list_offers(&self) -> MCPResponse {
        MCPResponse {
            result: serde_json::json!({
                "offers": [],
                "total": 0,
            }),
            error: None,
        }
    }

    fn handle_list_requests(&self) -> MCPResponse {
        MCPResponse {
            result: serde_json::json!({
                "requests": [],
                "total": 0,
            }),
            error: None,
        }
    }

    fn handle_find_matches(&self, params: serde_json::Value) -> MCPResponse {
        MCPResponse {
            result: serde_json::json!({
                "matches": [],
                "message": "Matching engine ready",
            }),
            error: None,
        }
    }

    fn handle_market_stats(&self) -> MCPResponse {
        MCPResponse {
            result: serde_json::json!({
                "active_offers": 0,
                "open_requests": 0,
                "total_matches": 0,
                "average_price_per_mbps": 0.0,
            }),
            error: None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unknown_method() {
        let server = MCPBrokerServer::new();
        let request = MCPRequest {
            method: "unknown".to_string(),
            params: serde_json::json!({}),
        };
        let response = server.handle_request(request);
        assert!(response.error.is_some());
    }

    #[test]
    fn test_list_offers() {
        let server = MCPBrokerServer::new();
        let request = MCPRequest {
            method: "list_offers".to_string(),
            params: serde_json::json!({}),
        };
        let response = server.handle_request(request);
        assert!(response.error.is_none());
    }
}
