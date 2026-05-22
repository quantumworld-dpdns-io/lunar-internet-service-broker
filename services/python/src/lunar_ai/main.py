from fastapi import FastAPI

app = FastAPI(
    title="Lunar AI Services",
    version="0.1.0",
    description="AI/ML services for Lunar Internet Service Broker",
)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "lunar-ai"}


@app.get("/api/v1/matches")
async def list_matches():
    return {"matches": []}


@app.post("/api/v1/matches/predict")
async def predict_match():
    return {"prediction": None}
