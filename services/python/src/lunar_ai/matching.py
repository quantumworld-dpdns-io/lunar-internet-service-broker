"""AI-powered matching engine."""

import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer


class AIMatchingEngine:
    """ML-enhanced matching for broker marketplace."""

    def __init__(self):
        self.vectorizer = TfidfVectorizer(max_features=100)
        self._fitted = False

    def compute_similarity(
        self, offer_description: str, request_description: str
    ) -> float:
        """Compute semantic similarity between offer and request."""
        corpus = [offer_description, request_description]
        vectors = self.vectorizer.fit_transform(corpus)
        self._fitted = True
        cos_sim = (vectors[0] @ vectors[1].T).toarray()[0][0]
        norm = np.linalg.norm(vectors[0].toarray()) * np.linalg.norm(
            vectors[1].toarray()
        )
        return float(cos_sim / norm) if norm > 0 else 0.0

    def predict_best_price(
        self,
        bandwidth_mbps: float,
        duration_hours: float,
        zone: str,
        historical_prices: list[float],
    ) -> float:
        """Predict optimal price based on historical data."""
        if not historical_prices:
            return bandwidth_mbps * 0.1  # default rate
        avg_price = np.mean(historical_prices)
        std_price = np.std(historical_prices) if len(historical_prices) > 1 else avg_price * 0.1
        bandwidth_factor = bandwidth_mbps / 100.0
        duration_factor = np.log(duration_hours + 1)
        return float(avg_price * bandwidth_factor * duration_factor)
