FROM python:3.12-slim-bookworm

WORKDIR /app
COPY pyproject.toml .
RUN pip install --no-cache-dir -e ".[dev]"
COPY src/ src/
EXPOSE 8082
CMD ["uvicorn", "src.lunar_ai.main:app", "--host", "0.0.0.0", "--port", "8082"]
