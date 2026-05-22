use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rover {
    pub id: Uuid,
    pub operator_id: Uuid,
    pub name: String,
    pub communication_requirements: CommunicationRequirements,
    pub location: LunarLocation,
    pub status: RoverStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Relay {
    pub id: Uuid,
    pub provider_id: Uuid,
    pub name: String,
    pub capacity_specs: CapacitySpecs,
    pub orbital_position: OrbitalPosition,
    pub status: RelayStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunicationRequirements {
    pub bandwidth_mbps: f64,
    pub frequency_ghz: f64,
    pub min_duration_secs: i64,
    pub max_latency_ms: f64,
    pub min_availability: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CapacitySpecs {
    pub total_bandwidth_mbps: f64,
    pub available_bandwidth_mbps: f64,
    pub frequency_range_ghz: (f64, f64),
    pub coverage_zone: LunarZone,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LunarLocation {
    pub latitude: f64,
    pub longitude: f64,
    pub zone: LunarZone,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrbitalPosition {
    pub altitude_km: f64,
    pub inclination_deg: f64,
    pub longitude_deg: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum LunarZone {
    Nearside,
    Farside,
    NorthPole,
    SouthPole,
    Equatorial,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RoverStatus {
    Active,
    Idle,
    Maintenance,
    Offline,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RelayStatus {
    Operational,
    Degraded,
    Offline,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CapacityOffer {
    pub id: Uuid,
    pub relay_id: Uuid,
    pub provider_id: Uuid,
    pub bandwidth_mbps: f64,
    pub price_per_mbps: f64,
    pub available_from: DateTime<Utc>,
    pub available_until: DateTime<Utc>,
    pub zone: LunarZone,
    pub status: OfferStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RelayRequest {
    pub id: Uuid,
    pub rover_id: Uuid,
    pub operator_id: Uuid,
    pub requirements: CommunicationRequirements,
    pub requested_from: DateTime<Utc>,
    pub requested_until: DateTime<Utc>,
    pub max_budget: f64,
    pub status: RequestStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MatchResult {
    pub id: Uuid,
    pub offer_id: Uuid,
    pub request_id: Uuid,
    pub score: f64,
    pub allocated_bandwidth_mbps: f64,
    pub total_price: f64,
    pub schedule_from: DateTime<Utc>,
    pub schedule_until: DateTime<Utc>,
    pub status: MatchStatus,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum OfferStatus {
    Active,
    Reserved,
    Fulfilled,
    Expired,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum RequestStatus {
    Open,
    Matched,
    Fulfilled,
    Expired,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum MatchStatus {
    Pending,
    Accepted,
    Committed,
    Completed,
    Disputed,
    Cancelled,
}
