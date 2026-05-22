"""Tests for AI matching engine."""

import pytest
from src.lunar_ai.matching import AIMatchingEngine


def test_compute_similarity():
    engine = AIMatchingEngine()
    score = engine.compute_similarity(
        "High bandwidth relay for lunar south pole",
        "Need 100Mbps relay at south pole",
    )
    assert 0.0 <= score <= 1.0


def test_predict_best_price():
    engine = AIMatchingEngine()
    price = engine.predict_best_price(
        bandwidth_mbps=100,
        duration_hours=24,
        zone="nearside",
        historical_prices=[10, 12, 11, 13, 9],
    )
    assert price > 0


def test_empty_historical_prices():
    engine = AIMatchingEngine()
    price = engine.predict_best_price(
        bandwidth_mbps=50,
        duration_hours=12,
        zone="farside",
        historical_prices=[],
    )
    assert price == 5.0  # 50 * 0.1
