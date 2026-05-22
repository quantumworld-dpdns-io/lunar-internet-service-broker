package types

import "time"

type User struct {
	ID             string    `json:"id"`
	AuthUserID     string    `json:"auth_user_id,omitempty"`
	Email          string    `json:"email"`
	DisplayName    string    `json:"display_name"`
	Role           string    `json:"role"`
	OrganizationID string    `json:"organization_id,omitempty"`
	IsVerified     bool      `json:"is_verified"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type Rover struct {
	ID                  string    `json:"id"`
	OperatorID          string    `json:"operator_id"`
	Name                string    `json:"name"`
	BandwidthMbps       float64   `json:"bandwidth_mbps"`
	FrequencyGHz        float64   `json:"frequency_ghz"`
	MinDurationSecs     int       `json:"min_duration_secs"`
	MaxLatencyMs        float64   `json:"max_latency_ms"`
	MinAvailability     float64   `json:"min_availability"`
	LocationLat         float64   `json:"location_lat"`
	LocationLon         float64   `json:"location_lon"`
	Zone                string    `json:"zone"`
	Status              string    `json:"status"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`
}

type LunarRelay struct {
	ID                    string    `json:"id"`
	ProviderID            string    `json:"provider_id"`
	Name                  string    `json:"name"`
	TotalBandwidthMbps    float64   `json:"total_bandwidth_mbps"`
	AvailableBandwidthMbps float64  `json:"available_bandwidth_mbps"`
	FrequencyRangeLowGHz  float64   `json:"frequency_range_low_ghz"`
	FrequencyRangeHighGHz float64   `json:"frequency_range_high_ghz"`
	AltitudeKm            float64   `json:"altitude_km"`
	InclinationDeg        float64   `json:"inclination_deg"`
	LongitudeDeg          float64   `json:"longitude_deg"`
	CoverageZone          string    `json:"coverage_zone"`
	Status                string    `json:"status"`
	CreatedAt             time.Time `json:"created_at"`
	UpdatedAt             time.Time `json:"updated_at"`
}

type CapacityOffer struct {
	ID             string    `json:"id"`
	RelayID        string    `json:"relay_id"`
	ProviderID     string    `json:"provider_id"`
	BandwidthMbps  float64   `json:"bandwidth_mbps"`
	PricePerMbps   float64   `json:"price_per_mbps"`
	Currency       string    `json:"currency"`
	AvailableFrom  time.Time `json:"available_from"`
	AvailableUntil time.Time `json:"available_until"`
	Zone           string    `json:"zone"`
	Status         string    `json:"status"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type RelayRequest struct {
	ID            string    `json:"id"`
	RoverID       string    `json:"rover_id"`
	OperatorID    string    `json:"operator_id"`
	BandwidthMbps float64   `json:"bandwidth_mbps"`
	MaxLatencyMs  float64   `json:"max_latency_ms"`
	MinAvailability float64 `json:"min_availability"`
	MaxBudget     float64   `json:"max_budget"`
	Currency      string    `json:"currency"`
	RequestedFrom time.Time `json:"requested_from"`
	RequestedUntil time.Time `json:"requested_until"`
	Zone          string    `json:"zone"`
	Status        string    `json:"status"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type MatchResult struct {
	ID                   string    `json:"id"`
	OfferID              string    `json:"offer_id"`
	RequestID            string    `json:"request_id"`
	Score                float64   `json:"score"`
	AllocatedBandwidthMbps float64 `json:"allocated_bandwidth_mbps"`
	TotalPrice           float64   `json:"total_price"`
	ScheduleFrom         time.Time `json:"schedule_from"`
	ScheduleUntil        time.Time `json:"schedule_until"`
	Status               string    `json:"status"`
	CreatedAt            time.Time `json:"created_at"`
}

type Commitment struct {
	ID                       string    `json:"id"`
	MatchID                  string    `json:"match_id"`
	BlockchainTxHash         string    `json:"blockchain_tx_hash,omitempty"`
	BlockchainContractAddress string   `json:"blockchain_contract_address,omitempty"`
	OnChainID                string    `json:"on_chain_id,omitempty"`
	Status                   string    `json:"status"`
	SignedAt                 *time.Time `json:"signed_at,omitempty"`
	ExpiresAt                *time.Time `json:"expires_at,omitempty"`
	CreatedAt                time.Time `json:"created_at"`
}
