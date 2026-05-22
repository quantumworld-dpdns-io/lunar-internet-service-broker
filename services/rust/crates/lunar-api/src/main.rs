use axum::{
    extract::State,
    http::Method,
    routing::get,
    Json, Router,
};
use lunar_core::types::*;
use lunar_matching::BasicMatchingEngine;
use serde::Serialize;
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::EnvFilter;

#[derive(Clone)]
struct AppState {
    matching_engine: Arc<BasicMatchingEngine>,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    service: String,
}

async fn health() -> Json<HealthResponse> {
    Json(HealthResponse {
        status: "ok".to_string(),
        service: "lunar-rust-api".to_string(),
    })
}

async fn list_offers() -> Json<Vec<CapacityOffer>> {
    Json(Vec::new())
}

async fn list_requests() -> Json<Vec<RelayRequest>> {
    Json(Vec::new())
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let cors = CorsLayer::new()
        .allow_methods([Method::GET, Method::POST])
        .allow_origin(Any);

    let state = AppState {
        matching_engine: Arc::new(BasicMatchingEngine),
    };

    let app = Router::new()
        .route("/health", get(health))
        .route("/api/v1/offers", get(list_offers))
        .route("/api/v1/requests", get(list_requests))
        .layer(cors)
        .with_state(state);

    let addr = "0.0.0.0:8081";
    tracing::info!("Rust API starting on {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
