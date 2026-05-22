use lunar_core::error::LunarError;
use lunar_core::traits::MatchingEngine;
use lunar_core::types::*;

pub struct BasicMatchingEngine;

#[async_trait::async_trait]
impl MatchingEngine for BasicMatchingEngine {
    async fn find_matches(
        &self,
        request: &RelayRequest,
        offers: &[CapacityOffer],
    ) -> Result<Vec<MatchResult>, LunarError> {
        let mut results = Vec::new();
        for offer in offers {
            let score = self.score_match(request, offer).await?;
            if score > 0.0 {
                results.push(MatchResult {
                    id: uuid::Uuid::new_v4(),
                    offer_id: offer.id,
                    request_id: request.id,
                    score,
                    allocated_bandwidth_mbps: offer.bandwidth_mbps.min(
                        request.requirements.bandwidth_mbps,
                    ),
                    total_price: offer.price_per_mbps * offer.bandwidth_mbps,
                    schedule_from: offer.available_from.max(request.requested_from),
                    schedule_until: offer.available_until.min(request.requested_until),
                    status: MatchStatus::Pending,
                });
            }
        }
        results.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap_or(std::cmp::Ordering::Equal));
        Ok(results)
    }

    async fn score_match(
        &self,
        request: &RelayRequest,
        offer: &CapacityOffer,
    ) -> Result<f64, LunarError> {
        let req = &request.requirements;
        if offer.available_from > request.requested_until
            || offer.available_until < request.requested_from
        {
            return Ok(0.0);
        }
        if offer.status != OfferStatus::Active {
            return Ok(0.0);
        }
        let bandwidth_score = (offer.bandwidth_mbps / req.bandwidth_mbps).min(1.0);
        let price_score = (req.max_budget / (offer.price_per_mbps * offer.bandwidth_mbps)).min(1.0);
        let availability_score = ((offer.available_until - offer.available_from).num_seconds() as f64
            / (request.requested_until - request.requested_from).num_seconds() as f64)
            .min(1.0);
        Ok(bandwidth_score * 0.4 + price_score * 0.35 + availability_score * 0.25)
    }
}
