.PHONY: help build test lint fmt clean dev

help:
	@echo "Lunar Internet Service Broker - Makefile"
	@echo ""
	@echo "Services:"
	@echo "  make build       Build all services"
	@echo "  make test        Run all tests"
	@echo "  make lint        Run all linters"
	@echo "  make fmt         Format all code"
	@echo "  make clean       Clean all build artifacts"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build    Build all Docker images"
	@echo "  make docker-up       Start all services"
	@echo "  make docker-down     Stop all services"
	@echo ""
	@echo "Dev:"
	@echo "  make dev             Start dev environment"
	@echo "  make dev-go          Start Go services"
	@echo "  make dev-rust        Start Rust services"
	@echo "  make dev-py          Start Python services"
	@echo "  make dev-julia       Start Julia services"
	@echo "  make dev-frontend    Start Next.js frontend"

# Go
build-go:
	cd services/go && go build ./...

test-go:
	cd services/go && go test ./...

lint-go:
	cd services/go && golangci-lint run && go vet ./...

fmt-go:
	cd services/go && go fmt ./...

# Rust
build-rust:
	cd services/rust && cargo build

test-rust:
	cd services/rust && cargo test

lint-rust:
	cd services/rust && cargo clippy --all && cargo fmt --all --check

fmt-rust:
	cd services/rust && cargo fmt --all

# Python
build-py:
	cd services/python && uv sync

test-py:
	cd services/python && pytest

lint-py:
	cd services/python && ruff check src/ && mypy src/

fmt-py:
	cd services/python && ruff format src/

# Julia
test-julia:
	cd services/julia && julia -e 'using Pkg; Pkg.test()'

# Solidity
build-solidity:
	cd services/solidity && forge build

test-solidity:
	cd services/solidity && forge test

lint-solidity:
	cd services/solidity && forge fmt --check

fmt-solidity:
	cd services/solidity && forge fmt

# Next.js
build-nextjs:
	cd services/nextjs && npm run build

test-nextjs:
	cd services/nextjs && npm run test

lint-nextjs:
	cd services/nextjs && npm run lint

dev-nextjs:
	cd services/nextjs && npm run dev

# Combined
build: build-go build-rust build-py build-solidity build-nextjs

test: test-go test-rust test-py test-solidity test-nextjs

lint: lint-go lint-rust lint-py lint-solidity lint-nextjs

fmt: fmt-go fmt-rust fmt-py fmt-solidity

# Docker
docker-build:
	docker compose build

docker-up:
	docker compose up -d

docker-down:
	docker compose down

# Dev
dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

dev-go:
	cd services/go && go run ./cmd/gateway

dev-rust:
	cd services/rust && cargo run -p lunar-api

dev-py:
	cd services/python && uvicorn src.lunar_ai.main:app --reload

# Clean
clean:
	rm -rf services/go/bin/
	cd services/rust && cargo clean
	rm -rf services/python/__pycache__/ services/python/.pytest_cache/
	rm -rf services/nextjs/.next/ services/nextjs/node_modules/
	rm -rf services/solidity/out/ services/solidity/cache/
