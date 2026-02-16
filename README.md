# playground

General-purpose project with Docker-based local Linux development.

## Projects

### hello_world

A Rust "hello world" app with unit tests. Located in `hello_world/`.

## Local Development

```bash
make build   # Build the Docker image
make shell   # Open an interactive shell in the container
make up      # Start the container in the background
make down    # Stop the container
make test    # Run cargo test inside the container
make lint    # Run cargo clippy inside the container
```

## CI

GitHub Actions runs on every push to `main` and on pull requests. To run the same checks locally:

```bash
make ci
```

## Code Review

Pull requests are automatically reviewed by Claude via the `claude-review` workflow. Mention `@claude` in a PR comment to ask follow-up questions.

## Branch Protection

`main` requires pull request reviews and passing CI status checks. No direct pushes.
