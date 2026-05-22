"""Vector store integration for semantic matching."""

from typing import Any, Optional, Union
import os


class VectorStore:
    """Abstract vector store with multi-backend support."""

    def __init__(self, backend: str = "qdrant"):
        self.backend = backend
        self.client = None
        self._connect()

    def _connect(self) -> None:
        if self.backend == "qdrant":
            from qdrant_client import QdrantClient
            url = os.getenv("QDRANT_URL", "http://localhost:6333")
            self.client = QdrantClient(url=url)
        elif self.backend == "chroma":
            import chromadb
            self.client = chromadb.Client()
        elif self.backend == "milvus":
            from pymilvus import connections
            connections.connect(host=os.getenv("MILVUS_HOST", "localhost"))
            self.client = connections

    def search_similar_offers(
        self, query_vector: list[float], limit: int = 10
    ) -> list[dict[str, Any]]:
        """Search for similar capacity offers using vector similarity."""
        if self.backend == "qdrant":
            results = self.client.search(
                collection_name="capacity_offers",
                query_vector=query_vector,
                limit=limit,
            )
            return [hit.payload for hit in results]
        return []

    def index_offer(self, offer_id: str, vector: list[float], payload: dict) -> None:
        """Index a capacity offer for vector search."""
        if self.backend == "qdrant":
            self.client.upsert(
                collection_name="capacity_offers",
                points=[{"id": offer_id, "vector": vector, "payload": payload}],
            )
