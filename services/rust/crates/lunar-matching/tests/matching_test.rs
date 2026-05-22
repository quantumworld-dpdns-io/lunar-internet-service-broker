use lunar_core::traits::MatchingEngine;
use lunar_core::types::*;
use lunar_matching::BasicMatchingEngine;
use uuid::Uuid;
use chrono::{Duration, Utc};

#[tokio::test]
async fn test_basic_matching() {
    let engine = BasicMatchingEngine;
    let request = RelayRequest {
        id: Uuid::new_v4(),
        rover_id: Uuid::new_v4(),
        operator_id: Uuid::new_v4(),
        requirements: CommunicationRequirements {
            bandwidth_mbps: 100.0,
            frequency_ghz: 2.4,
            min_duration_secs: 3600,
            max_latency_ms: 500.0,
            min_availability: 0.95,
        },
        requested_from: Utc::now(),
        requested_until: Utc::now() + Duration::hours(24),
        max_budget: 1000.0,
        status: RequestStatus::Open,
    };

    let offers = vec![
        CapacityOffer {
            id: Uuid::new_v4(),
            relay_id: Uuid::new_v4(),
            provider_id: Uuid::new_v4(),
            bandwidth_mbps: 200.0,
            price_per_mbps: 0.5,
            available_from: Utc::now(),
            available_until: Utc::now() + Duration::hours(48),
            zone: LunarZone::Nearside,
            status: OfferStatus::Active,
        },
    ];

    let results = engine.find_matches(&request, &offers).await.unwrap();
    assert!(!results.is_empty(), "Expected at least one match");
    assert!(results[0].score > 0.0, "Expected positive score");
}

#[tokio::test]
async fn test_no_match_for_different_zones() {
    let engine = BasicMatchingEngine;
    let request = RelayRequest {
        id: Uuid::new_v4(),
        rover_id: Uuid::new_v4(),
        operator_id: Uuid::new_v4(),
        requirements: CommunicationRequirements {
            bandwidth_mbps: 100.0,
            frequency_ghz: 2.4,
            min_duration_secs: 3600,
            max_latency_ms: 500.0,
            min_availability: 0.95,
        },
        requested_from: Utc::now(),
        requested_until: Utc::now() + Duration::hours(24),
        max_budget: 1000.0,
        status: RequestStatus::Open,
    };

    let offers = vec![
        CapacityOffer {
            id: Uuid::new_v4(),
            relay_id: Uuid::new_v4(),
            provider_id: Uuid::new_v4(),
            bandwidth_mbps: 200.0,
            price_per_mbps: 0.5,
            available_from: Utc::now() - Duration::days(10),
            available_until: Utc::now() - Duration::days(5),
            zone: LunarZone::SouthPole,
            status: OfferStatus::Active,
        },
    ];

    let results = engine.find_matches(&request, &offers).await.unwrap();
    assert!(results.is_empty(), "Expected no matches for past availability");
}
