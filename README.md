# playground

General-purpose project with Docker-based local Linux development.

## Local Development

```bash
make build   # Build the Docker image
make shell   # Open an interactive shell in the container
make up      # Start the container in the background
make down    # Stop the container
```

## CI

GitHub Actions runs on every push to `main` and on pull requests. To run the same checks locally:

```bash
make ci
```

## Branch Protection

`main` requires pull request reviews and passing CI status checks. No direct pushes.
