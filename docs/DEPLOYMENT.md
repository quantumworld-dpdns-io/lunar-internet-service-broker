# Deployment Guide

## Local Development

```bash
# Start infrastructure
docker compose up -d

# Start individual service
make dev-go     # Go gateway
make dev-rust   # Rust API
make dev-py     # Python AI
make dev-frontend  # Next.js
```

## Docker Swarm

```bash
# Deploy to swarm cluster
docker stack deploy -c infra/swarm/docker-stack.yml lunar-broker

# Monitor
docker stack services lunar-broker
docker service logs lunar-broker_gateway
```

## Kubernetes

```bash
# Create namespace and secrets
kubectl apply -f infra/k8s/namespace.yaml
kubectl apply -f infra/k8s/secrets.yaml

# Deploy services
kubectl apply -f infra/k8s/gateway-deployment.yaml
kubectl apply -f infra/k8s/rust-api-deployment.yaml
kubectl apply -f infra/k8s/frontend-deployment.yaml

# Ingress
kubectl apply -f infra/k8s/ingress.yaml

# Auto-scaling
kubectl apply -f infra/k8s/hpa.yaml
```

## Helm

```bash
# Install
helm install lunar-broker infra/helm/lunar-broker \
  --values infra/helm/lunar-broker/values.yaml

# Upgrade
helm upgrade lunar-broker infra/helm/lunar-broker

# Uninstall
helm uninstall lunar-broker
```

## Pulumi (Cloud)

```bash
cd infra/pulumi
pulumi stack select dev
pulumi up --yes
```

## CI/CD Pipeline

GitHub Actions workflows in `.github/workflows/ci.yml`:
- **lint**: Static analysis for all languages
- **build**: Compilation checks
- **test**: All test suites
- **security**: Trivy scanning
- **docker**: Build and push Docker images
