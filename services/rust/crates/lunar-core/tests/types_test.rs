use lunar_core::types::*;
use uuid::Uuid;
use chrono::Utc;

#[test]
fn test_create_rover() {
    let rover = Rover {
        id: Uuid::new_v4(),
        operator_id: Uuid::new_v4(),
        name: "Test Rover".to_string(),
        communication_requirements: CommunicationRequirements {
            bandwidth_mbps: 100.0,
            frequency_ghz: 2.4,
            min_duration_secs: 3600,
            max_latency_ms: 500.0,
            min_availability: 0.99,
        },
        location: LunarLocation {
            latitude: 0.0,
            longitude: 0.0,
            zone: LunarZone::Nearside,
        },
        status: RoverStatus::Active,
    };
    assert_eq!(rover.name, "Test Rover");
    assert_eq!(rover.status, RoverStatus::Active);
}

#[test]
fn test_create_capacity_offer() {
    let offer = CapacityOffer {
        id: Uuid::new_v4(),
        relay_id: Uuid::new_v4(),
        provider_id: Uuid::new_v4(),
        bandwidth_mbps: 50.0,
        price_per_mbps: 0.5,
        available_from: Utc::now(),
        available_until: Utc::now(),
        zone: LunarZone::SouthPole,
        status: OfferStatus::Active,
    };
    assert_eq!(offer.bandwidth_mbps, 50.0);
    assert_eq!(offer.zone, LunarZone::SouthPole);
}

#[test]
fn test_match_result_sorting() {
    let mut matches = vec![
        MatchResult {
            id: Uuid::new_v4(), offer_id: Uuid::new_v4(), request_id: Uuid::new_v4(),
            score: 0.5, allocated_bandwidth_mbps: 100.0, total_price: 50.0,
            schedule_from: Utc::now(), schedule_until: Utc::now(),
            status: MatchStatus::Pending,
        },
        MatchResult {
            id: Uuid::new_v4(), offer_id: Uuid::new_v4(), request_id: Uuid::new_v4(),
            score: 0.9, allocated_bandwidth_mbps: 100.0, total_price: 50.0,
            schedule_from: Utc::now(), schedule_until: Utc::now(),
            status: MatchStatus::Pending,
        },
    ];
    matches.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap());
    assert_eq!(matches[0].score, 0.9);
}
