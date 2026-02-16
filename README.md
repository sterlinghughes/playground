# playground

General-purpose project with Docker-based local Linux development.

## Projects

### hello_world

A Rust "hello world" app with unit tests. Located in `hello_world/`.

### hello_service

A Rust gRPC service using tonic/prost with a `Greeter.SayHello` RPC. Located in `hello_service/`.

- **hello-server** — gRPC server on port 50051
- **hello-client** — CLI client with `--addr` and `--name` flags
- **Proto** — `hello_service/proto/hello.proto`

```bash
make hello_service          # Build hello_service
make hello_service_test     # Run unit tests
make hello_service_lint     # Run clippy
make hello_service_server   # Start the gRPC server (port 50051)
make hello_service_client ARGS="--name Alice"  # Run the client
```

## Local Development

```bash
make build   # Build the Docker image
make shell   # Open an interactive shell in the container
make up      # Start the container in the background
make down    # Stop the container
make test    # Run cargo test inside the container
make lint    # Run cargo clippy inside the container
```

## Kubernetes (kind)

Local Kubernetes development using [kind](https://kind.sigs.k8s.io/). Generic targets accept these variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `CLUSTER_NAME` | `playground` | kind cluster name |
| `SERVICE_NAME` | `hello-service` | Docker image and K8s resource name |
| `SERVICE_DIR` | `hello_service` | Directory containing the service Dockerfile |
| `SERVICE_PORT` | `50051` | Port for the service |
| `SERVICE_TEST_CMD` | *(hello-client)* | Command to run for integration test |

```bash
make kind_create             # Create a kind cluster
make kind_deploy             # Build image, load into kind, apply manifests
make kind_status             # Show pod and service status
make kind_port_forward       # Forward localhost port to the service
make kind_integration_test   # Deploy and run client against the service
make kind_undeploy           # Remove K8s resources
make kind_delete             # Delete the kind cluster

# Example with explicit variables:
make kind_deploy SERVICE_NAME=my-svc SERVICE_DIR=my_service SERVICE_PORT=8080
```

hello_service convenience targets:

```bash
make hello_service_deploy             # Deploy hello-service to kind
make hello_service_status             # Show hello-service pod/svc status
make hello_service_port_forward       # Forward localhost:50051
make hello_service_integration_test   # End-to-end test in kind
make hello_service_undeploy           # Remove hello-service from kind
```

## CI

GitHub Actions runs on every push to `main` and on pull requests. The pipeline includes:

1. **build** — Docker build, health check, lint and test for all projects
2. **integration** — kind cluster deploy and end-to-end gRPC client test

To run the same checks locally:

```bash
make ci
```

## Code Review

Pull requests are automatically reviewed by Claude via the `claude-review` workflow. Mention `@claude` in a PR comment to ask follow-up questions.

## Branch Protection

`main` requires pull request reviews and passing CI status checks. No direct pushes.
