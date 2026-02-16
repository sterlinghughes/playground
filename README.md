# playground

Rust projects with a Nix dev environment, CentOS Stream 10 production containers, and local Kubernetes via kind.

## Project Layout

```
hello_world/          Rust "hello world" with unit tests
hello_service/        Rust gRPC service (tonic/prost)
opt/
  k8s/base/           Kubernetes manifests (Kustomize)
  nix/vm/             NixOS VM config (kernel 6.19 + Docker)
  docker-compose.yml  Backing services (placeholder)
flake.nix             Nix dev shell
```

## Projects

### hello_world

A simple Rust binary with unit tests.

### hello_service

A gRPC service with a `Greeter.SayHello` RPC.

- **hello-server** — listens on port 50051
- **hello-client** — CLI with `--addr` and `--name` flags
- **Proto** — `hello_service/proto/hello.proto`

```bash
make hello_service          # Build
make hello_service_test     # Unit tests
make hello_service_lint     # Clippy
make hello_service_server   # Start the server
make hello_service_client ARGS="--name Alice"
```

## Local Development

### Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

### Dev Shell

```bash
nix develop      # Enter the dev shell (rustc, cargo, clippy, protobuf, kubectl, kind)
direnv allow     # Or auto-activate with direnv
```

```bash
make test        # hello_world tests
make lint        # hello_world clippy
make ci          # All lints and tests
```

### Production Image

CentOS Stream 10 runtime base:

```bash
docker build -t hello-service:latest hello_service/
```

## Kubernetes (kind)

Manifests in `opt/k8s/base/`, managed with [Kustomize](https://kustomize.io/). The `kind_deploy` target generates a Kustomize overlay from `SERVICE_PORT`.

| Variable | Default | Description |
|----------|---------|-------------|
| `CLUSTER_NAME` | `playground` | kind cluster name |
| `SERVICE_NAME` | `hello-service` | Docker image and K8s resource name |
| `SERVICE_DIR` | `hello_service` | Directory containing the service Dockerfile |
| `SERVICE_PORT` | `50051` | Port for the service |

```bash
make kind_create             # Create cluster
make kind_deploy             # Build, load, apply
make kind_status             # Pod and service status
make kind_port_forward       # Forward localhost to service
make kind_integration_test   # Deploy + e2e test
make kind_undeploy           # Remove resources
make kind_delete             # Delete cluster
```

hello_service shortcuts:

```bash
make hello_service_deploy
make hello_service_integration_test
make hello_service_undeploy
```

## NixOS VM (kernel 6.19)

NixOS configuration in `opt/nix/vm/` for a local VM running kernel 6.19 with Docker.

```bash
cd opt/nix/vm
nix build .#nixosConfigurations.playground-vm.config.system.build.vm
./result/bin/run-playground-vm-vm
```

Connect Docker to the VM:

```bash
export DOCKER_HOST=tcp://localhost:2375
docker info
```

## CI

GitHub Actions with Nix + Cachix binary caching:

1. **build** — lint and test all projects via `nix develop`
2. **integration** — kind cluster deploy + gRPC e2e test

```bash
make ci          # Run the same checks locally
```

## Code Review

PRs are reviewed by Claude via the `claude-review` workflow. Mention `@claude` in a PR comment for follow-ups.

## Branch Protection

`main` requires PR reviews and passing CI. No direct pushes.
