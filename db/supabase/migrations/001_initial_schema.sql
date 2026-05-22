-- Lunar Internet Service Broker - Initial Schema
-- Migration 001: Core tables and relationships

-- ── Enums ──────────────────────────────────────
CREATE TYPE user_role AS ENUM ('admin', 'operator', 'provider', 'arbitrator');
CREATE TYPE rover_status AS ENUM ('active', 'idle', 'maintenance', 'offline');
CREATE TYPE relay_status AS ENUM ('operational', 'degraded', 'offline');
CREATE TYPE lunar_zone AS ENUM ('nearside', 'farside', 'north_pole', 'south_pole', 'equatorial');
CREATE TYPE offer_status AS ENUM ('active', 'reserved', 'fulfilled', 'expired', 'cancelled');
CREATE TYPE request_status AS ENUM ('open', 'matched', 'fulfilled', 'expired', 'cancelled');
CREATE TYPE match_status AS ENUM ('pending', 'accepted', 'committed', 'completed', 'disputed', 'cancelled');
CREATE TYPE commitment_status AS ENUM ('active', 'fulfilled', 'breached', 'cancelled');
CREATE TYPE transaction_type AS ENUM ('deposit', 'release', 'refund', 'fee', 'penalty');
CREATE TYPE transaction_status AS ENUM ('pending', 'confirmed', 'failed');
CREATE TYPE dispute_status AS ENUM ('open', 'investigating', 'resolved', 'appealed');

-- ── Extension ──────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_graphql";

-- ── Core Tables ────────────────────────────────

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE REFERENCES auth.users(id),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    role user_role NOT NULL DEFAULT 'operator',
    organization_id UUID,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    website TEXT,
    country TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE profiles ADD FOREIGN KEY (organization_id) REFERENCES organizations(id);

CREATE TABLE rovers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operator_id UUID NOT NULL REFERENCES profiles(id),
    name TEXT NOT NULL,
    model TEXT,
    bandwidth_mbps NUMERIC NOT NULL,
    frequency_ghz NUMERIC,
    min_duration_secs INTEGER,
    max_latency_ms NUMERIC,
    min_availability NUMERIC DEFAULT 0.95,
    location_lat NUMERIC,
    location_lon NUMERIC,
    zone lunar_zone NOT NULL,
    status rover_status DEFAULT 'idle',
    specifications JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE lunar_relays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES profiles(id),
    name TEXT NOT NULL,
    total_bandwidth_mbps NUMERIC NOT NULL,
    available_bandwidth_mbps NUMERIC NOT NULL,
    frequency_range_low_ghz NUMERIC,
    frequency_range_high_ghz NUMERIC,
    altitude_km NUMERIC,
    inclination_deg NUMERIC,
    longitude_deg NUMERIC,
    coverage_zone lunar_zone NOT NULL,
    status relay_status DEFAULT 'operational',
    specifications JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ── Marketplace Tables ─────────────────────────

CREATE TABLE capacity_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    relay_id UUID NOT NULL REFERENCES lunar_relays(id),
    provider_id UUID NOT NULL REFERENCES profiles(id),
    bandwidth_mbps NUMERIC NOT NULL,
    price_per_mbps NUMERIC NOT NULL,
    currency TEXT DEFAULT 'USD',
    available_from TIMESTAMPTZ NOT NULL,
    available_until TIMESTAMPTZ NOT NULL,
    zone lunar_zone NOT NULL,
    status offer_status DEFAULT 'active',
    terms TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE relay_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rover_id UUID NOT NULL REFERENCES rovers(id),
    operator_id UUID NOT NULL REFERENCES profiles(id),
    bandwidth_mbps NUMERIC NOT NULL,
    max_latency_ms NUMERIC,
    min_availability NUMERIC DEFAULT 0.95,
    max_budget NUMERIC,
    currency TEXT DEFAULT 'USD',
    requested_from TIMESTAMPTZ NOT NULL,
    requested_until TIMESTAMPTZ NOT NULL,
    zone lunar_zone NOT NULL,
    description TEXT,
    status request_status DEFAULT 'open',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE match_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    offer_id UUID NOT NULL REFERENCES capacity_offers(id),
    request_id UUID NOT NULL REFERENCES relay_requests(id),
    score NUMERIC NOT NULL,
    allocated_bandwidth_mbps NUMERIC NOT NULL,
    total_price NUMERIC NOT NULL,
    schedule_from TIMESTAMPTZ NOT NULL,
    schedule_until TIMESTAMPTZ NOT NULL,
    status match_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE commitments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES match_results(id),
    blockchain_tx_hash TEXT,
    blockchain_contract_address TEXT,
    on_chain_id TEXT,
    terms TEXT,
    status commitment_status DEFAULT 'active',
    signed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID REFERENCES commitments(id),
    from_profile_id UUID NOT NULL REFERENCES profiles(id),
    to_profile_id UUID REFERENCES profiles(id),
    amount NUMERIC NOT NULL,
    currency TEXT DEFAULT 'USD',
    tx_type transaction_type NOT NULL,
    status transaction_status DEFAULT 'pending',
    blockchain_tx_hash TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE escrow_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID NOT NULL UNIQUE REFERENCES commitments(id),
    amount NUMERIC NOT NULL,
    held_by UUID NOT NULL REFERENCES profiles(id),
    released_to UUID REFERENCES profiles(id),
    status TEXT DEFAULT 'held',
    released_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID NOT NULL REFERENCES commitments(id),
    raised_by UUID NOT NULL REFERENCES profiles(id),
    reason TEXT NOT NULL,
    evidence JSONB DEFAULT '{}',
    status dispute_status DEFAULT 'open',
    resolved_by UUID REFERENCES profiles(id),
    resolution TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID NOT NULL REFERENCES commitments(id),
    rater_id UUID NOT NULL REFERENCES profiles(id),
    ratee_id UUID NOT NULL REFERENCES profiles(id),
    score INTEGER CHECK (score >= 1 AND score <= 5),
    review TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id),
    title TEXT NOT NULL,
    body TEXT,
    type TEXT NOT NULL,
    reference_type TEXT,
    reference_id UUID,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    details JSONB DEFAULT '{}',
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type TEXT NOT NULL,
    profile_id UUID REFERENCES profiles(id),
    properties JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Indexes ────────────────────────────────────

CREATE INDEX idx_offers_status ON capacity_offers(status);
CREATE INDEX idx_offers_zone ON capacity_offers(zone);
CREATE INDEX idx_offers_available ON capacity_offers(available_from, available_until);
CREATE INDEX idx_offers_provider ON capacity_offers(provider_id);
CREATE INDEX idx_requests_status ON relay_requests(status);
CREATE INDEX idx_requests_zone ON relay_requests(zone);
CREATE INDEX idx_requests_operator ON relay_requests(operator_id);
CREATE INDEX idx_matches_status ON match_results(status);
CREATE INDEX idx_matches_offer ON match_results(offer_id);
CREATE INDEX idx_matches_request ON match_results(request_id);
CREATE INDEX idx_commitments_status ON commitments(status);
CREATE INDEX idx_commitments_blockchain ON commitments(blockchain_tx_hash);
CREATE INDEX idx_notifications_profile ON notifications(profile_id, is_read);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at);
CREATE INDEX idx_analytics_type ON analytics_events(event_type, created_at);

-- ── Row Level Security ─────────────────────────

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE rovers ENABLE ROW LEVEL SECURITY;
ALTER TABLE lunar_relays ENABLE ROW LEVEL SECURITY;
ALTER TABLE capacity_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE relay_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE escrow_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read public profiles, update own
CREATE POLICY profiles_select ON profiles FOR SELECT USING (true);
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (auth.uid() = auth_user_id);

-- Organizations: members can read, admins can update
CREATE POLICY orgs_select ON organizations FOR SELECT USING (true);
CREATE POLICY orgs_update ON organizations FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.organization_id = organizations.id AND profiles.auth_user_id = auth.uid())
);

-- Rovers: operators manage own, others can read
CREATE POLICY rovers_select ON rovers FOR SELECT USING (true);
CREATE POLICY rovers_insert ON rovers FOR INSERT WITH CHECK (
    operator_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);
CREATE POLICY rovers_update ON rovers FOR UPDATE USING (
    operator_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);

-- Offers: providers manage own, all can read
CREATE POLICY offers_select ON capacity_offers FOR SELECT USING (true);
CREATE POLICY offers_insert ON capacity_offers FOR INSERT WITH CHECK (
    provider_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);
CREATE POLICY offers_update ON capacity_offers FOR UPDATE USING (
    provider_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);

-- Requests: operators manage own, all can read
CREATE POLICY requests_select ON relay_requests FOR SELECT USING (true);
CREATE POLICY requests_insert ON relay_requests FOR INSERT WITH CHECK (
    operator_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);
CREATE POLICY requests_update ON relay_requests FOR UPDATE USING (
    operator_id IN (SELECT id FROM profiles WHERE auth_user_id = auth.uid())
);

-- ── Functions & Triggers ───────────────────────

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER rovers_updated_at BEFORE UPDATE ON rovers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER relays_updated_at BEFORE UPDATE ON lunar_relays
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER offers_updated_at BEFORE UPDATE ON capacity_offers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER requests_updated_at BEFORE UPDATE ON relay_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER matches_updated_at BEFORE UPDATE ON match_results
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER commitments_updated_at BEFORE UPDATE ON commitments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Audit log function
CREATE OR REPLACE FUNCTION log_audit_event()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (profile_id, action, entity_type, entity_id, details)
    VALUES (
        auth.uid(),
        TG_ARGV[0]::TEXT,
        TG_TABLE_NAME,
        NEW.id,
        row_to_json(NEW)::JSONB
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Notification function
CREATE OR REPLACE FUNCTION notify_match_created()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (profile_id, title, body, type, reference_type, reference_id)
    VALUES (
        (SELECT operator_id FROM relay_requests WHERE id = NEW.request_id),
        'Match Found',
        'A matching capacity offer has been found for your request',
        'match',
        'match_result',
        NEW.id
    );
    INSERT INTO notifications (profile_id, title, body, type, reference_type, reference_id)
    VALUES (
        (SELECT provider_id FROM capacity_offers WHERE id = NEW.offer_id),
        'Match Found',
        'Your capacity offer has been matched to a request',
        'match',
        'match_result',
        NEW.id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER match_created_notification
    AFTER INSERT ON match_results
    FOR EACH ROW EXECUTE FUNCTION notify_match_created();
