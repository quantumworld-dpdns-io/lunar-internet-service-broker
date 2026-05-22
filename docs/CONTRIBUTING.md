# Contributing to Lunar Internet Service Broker

## Getting Started

1. Read the [ARCHITECTURE.md](ARCHITECTURE.md) and [AGENTS.md](../AGENTS.md)
2. Check the [PLAN.md](../PLAN.md) for current phase and todos
3. Pick a todo item and implement it

## Development Workflow

1. Branch from `dev`: `git checkout -b feature/my-feature dev`
2. Implement changes following code style (see AGENTS.md)
3. Write tests (unit + integration)
4. Run linters and type checkers
5. Commit with message format: `phase-N: description`
6. Push and open PR to `dev`

## Code Style

- **Go**: Standard Go conventions, `gofmt` formatting
- **Rust**: Clippy-clean, `rustfmt` formatting
- **Python**: PEP 8, type hints required for public functions
- **Solidity**: Solidity Style Guide, NatSpec comments
- **TypeScript**: Strict mode, no `any`
- **Robot Framework**: Page Object pattern for UI, data-driven for API

## Testing Requirements

- All new code must include tests
- API changes need Robot Framework tests
- Smart contracts need Forge unit + fuzz tests
- OWASP Top 10 tests for security coverage
- Frontend changes need Vitest + Playwright tests

## Pull Request Process

1. Ensure all CI checks pass
2. Update documentation if needed
3. Request review from relevant code owners
4. Squash commits before merge
