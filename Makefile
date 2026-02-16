.PHONY: build shell up down test lint ci \
       hello_world \
       hello_service hello_service_test hello_service_lint hello_service_server hello_service_client

SERVICE_PORT ?= 50051

build:
	docker compose build

shell: up
	docker compose exec dev bash

up:
	docker compose up -d

down:
	docker compose down

test:
	docker compose run --rm dev bash -c "cd hello_world && cargo test"

lint:
	docker compose run --rm dev bash -c "cd hello_world && cargo clippy -- -D warnings"

hello_world:
	docker compose run --rm dev bash -c "cd hello_world && cargo run --release"

hello_service:
	docker compose run --rm dev bash -c "cd hello_service && cargo build --release"

hello_service_test:
	docker compose run --rm dev bash -c "cd hello_service && cargo test"

hello_service_lint:
	docker compose run --rm dev bash -c "cd hello_service && cargo clippy -- -D warnings"

hello_service_server:
	docker compose run --rm -p $(SERVICE_PORT):$(SERVICE_PORT) dev bash -c "cd hello_service && PORT=$(SERVICE_PORT) cargo run --release --bin hello-server"

hello_service_client:
	docker compose run --rm dev bash -c "cd hello_service && cargo run --release --bin hello-client -- $(ARGS)"

ci:
	docker compose build
	docker compose run --rm dev bash -c "echo 'Health check: OK' && uname -a"
	docker compose run --rm dev bash -c "cd hello_world && cargo clippy -- -D warnings"
	docker compose run --rm dev bash -c "cd hello_world && cargo test"
	docker compose run --rm dev bash -c "cd hello_service && cargo clippy -- -D warnings"
	docker compose run --rm dev bash -c "cd hello_service && cargo test"
