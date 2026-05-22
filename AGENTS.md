# Lunar Internet Service Broker — Conventions & Commands

## Project Structure

```
/
├── services/
│   ├── go/           # Go API Gateway & microservices
│   ├── rust/         # Rust core services (matching, crypto, blockchain)
│   ├── python/       # Python AI/ML services
│   ├── julia/        # Julia optimization engine
│   ├── solidity/     # Smart contracts (Foundry)
│   ├── qasm/         # Quantum assembly components
│   └── nextjs/       # Next.js frontend
├── infra/
│   ├── nginx/        # Nginx reverse proxy config
│   ├── pulumi/       # Pulumi IaC
│   ├── k8s/          # Kubernetes manifests
│   ├── swarm/        # Docker Compose / Swarm stacks
│   └── helm/         # Helm charts
├── tests/
│   └── robot/        # Robot Framework test suites
├── scripts/          # Dev helper scripts (gitignored)
├── docs/             # Documentation
└── db/               # Supabase migrations & edge functions
```

## Branching

- `main` — production-ready, protected
- `dev` — active development, all commits go here
- feature branches optional per-task (merge to `dev`)

## Commit Convention

```
phase-N: short description

# Examples:
# phase-0: initialize monorepo root structure
# phase-1: create users table migration
# phase-3: implement LunarRelayToken ERC-20 contract
```

Each commit is atomic (one logical change).

## Per-Language Commands

### Go (`services/go/`)
```
cd services/go
go build ./...          # Build all packages
go test ./...           # Run all tests
go vet ./...            # Static analysis
golangci-lint run       # Lint all packages
go fmt ./...            # Format code
go mod tidy             # Clean dependencies
```

### Rust (`services/rust/`)
```
cd services/rust
cargo build              # Build workspace
cargo test               # Run all tests
cargo clippy --all       # Lint all crates
cargo fmt --all          # Format code
cargo audit              # Dependency audit
cargo deny check         # License compliance
cargo tarpaulin --all    # Code coverage
cargo bench              # Run benchmarks
```

### Python (`services/python/`)
```
cd services/python
uv sync                    # Install deps (or poetry install)
ruff check src/            # Lint
ruff format src/           # Format
mypy src/                  # Type check
pytest                     # Run tests
pytest --cov=src/          # Coverage
```

### Julia (`services/julia/`)
```
cd services/julia
julia -e 'using Pkg; Pkg.test()'   # Run tests
julia -e 'using Pkg; Pkg.instantiate()'  # Install deps
```

### Solidity (`services/solidity/`)
```
cd services/solidity
forge build              # Build contracts
forge test               # Run tests
forge coverage           # Coverage report
forge snapshot           # Gas report
forge fmt                # Format code
slither .                # Static analysis
```

### Next.js (`services/nextjs/`)
```
cd services/nextjs
npm install              # Install deps
npm run dev              # Dev server
npm run build            # Production build
npm run lint             # Lint (ESLint)
npm run typecheck        # TypeScript check
npm run test             # Vitest unit tests
npx playwright test      # E2E tests
```

### Robot Framework (`tests/robot/`)
```
cd tests/robot
pip install -r requirements.txt
robot --outputdir results tests/
robot --include security tests/          # Security tests only
robot --include owasp tests/            # OWASP tests only
```

### Docker
```
docker compose build        # Build all services
docker compose up           # Start all services
docker compose down         # Stop all services
docker compose run --rm test # Run tests in CI
```

### Infrastructure
```
# Pulumi
cd infra/pulumi
pulumi up                   # Deploy infrastructure
pulumi preview              # Preview changes
pulumi destroy              # Tear down

# K8s
kubectl apply -f infra/k8s/
helm install lunar-broker infra/helm/lunar-broker

# Nginx
docker compose -f infra/nginx/docker-compose.yml up
```

## Code Style

- **Go**: Standard Go conventions, error wrapping with `%w`, context propagation
- **Rust**: Clippy warnings as errors, no unsafe unless documented
- **Python**: PEP 8 (ruff enforced), type hints required for all public functions
- **Julia**: Julia style guide, JuMP conventions for optimization models
- **Solidity**: Solidity Style Guide, NatSpec comments on all public functions
- **TypeScript**: Strict mode, explicit return types, no `any`
- **Robot Framework**: Page Object pattern for UI, data-driven for API

## Testing Requirements

- All new code must have tests
- API changes must include Robot Framework tests
- Smart contracts must have Forge unit + fuzz + invariant tests
- OWASP Top 10 tests in Robot Framework for security coverage
- Frontend changes need Vitest component + Playwright e2e tests
