# Lunar Internet Service Broker

> Marketplace matching rovers/payloads with lunar communication relay capacity via on-chain commitments

[![CI](https://github.com/quantumworld-dpdns-io/lunar-internet-service-broker/actions/workflows/ci.yml/badge.svg)](https://github.com/quantumworld-dpdns-io/lunar-internet-service-broker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go)](services/go)
[![Rust](https://img.shields.io/badge/Rust-1.80+-DEA584?logo=rust)](services/rust)
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python)](services/python)
[![Solidity](https://img.shields.io/badge/Solidity-0.8+-363636?logo=solidity)](services/solidity)
[![Next.js](https://img.shields.io/badge/Next.js-14-000000?logo=nextdotjs)](services/nextjs)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase)](db)

## Overview

This repository is part of the [quantumworld-dpdns-io](https://github.com/quantumworld-dpdns-io) Wild SaaS & Tech Development initiative.

The broker is a multi-language, multi-service platform for matching lunar communication relay capacity with rover/payload operators on the Moon. Commitments are recorded on-chain via smart contracts.

### Services

| Service | Language | Role |
|---------|----------|------|
| API Gateway | Go | REST/GraphQL API, auth, routing |
| Core Engine | Rust | Matching, crypto, blockchain interaction |
| AI/ML | Python | Matching AI, NLP, vector search, agents |
| Optimization | Julia | Capacity planning, orbital mechanics |
| Smart Contracts | Solidity | On-chain commitments, token, escrow, DAO |
| Quantum | QASM | Quantum communication simulation, QKD |
| Frontend | Next.js | Dashboard, marketplace UI, wallet |

### Infrastructure

| Component | Tech |
|-----------|------|
| Database | Supabase (PostgreSQL) |
| Proxy | Nginx |
| IaC | Pulumi |
| Orchestration | K8s / Docker Swarm / Helm |
| Testing | Robot Framework + OWASP Top 10 |

## Quick Start

```bash
git clone https://github.com/quantumworld-dpdns-io/lunar-internet-service-broker.git
cd lunar-internet-service-broker

# Start infrastructure
docker compose up -d

# Start individual service (e.g. Go gateway)
cd services/go && go run ./cmd/gateway
```

## Project Structure

```
.
├── services/       # Multi-language service code
│   ├── go/         # Go API Gateway & microservices
│   ├── rust/       # Rust core services
│   ├── python/     # Python AI/ML services
│   ├── julia/      # Julia optimization engine
│   ├── solidity/   # Smart contracts (Foundry)
│   ├── qasm/       # Quantum assembly components
│   └── nextjs/     # Next.js frontend
├── infra/          # Infrastructure
│   ├── nginx/      # Nginx proxy config
│   ├── pulumi/     # Pulumi IaC
│   ├── k8s/        # Kubernetes manifests
│   ├── swarm/      # Docker Compose / Swarm stacks
│   └── helm/       # Helm charts
├── db/             # Supabase migrations & edge functions
├── tests/          # Test suites
│   └── robot/      # Robot Framework tests (including OWASP)
├── docs/           # Documentation
└── scripts/        # Dev helper scripts
```

## Development

See [AGENTS.md](AGENTS.md) for per-language build, test, and lint commands.

### Prerequisites

- Docker & Docker Compose
- Go 1.22+
- Rust 1.80+
- Python 3.12+
- Julia 1.10+
- Foundry (Solidity)
- Node.js 20+
- Supabase CLI

## CI/CD

GitHub Actions workflows:
- **CI**: Build, lint, test for all services
- **Security**: OWASP Top 10 + dependency scanning
- **Deploy**: Multi-stage Docker builds + Pulumi

## Contributing

Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before opening a pull request.

## License

[MIT](LICENSE)
