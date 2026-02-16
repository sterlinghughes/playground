.PHONY: build shell up down test lint ci hello_world

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

ci:
	docker compose build
	docker compose run --rm dev bash -c "echo 'Health check: OK' && uname -a"
	docker compose run --rm dev bash -c "cd hello_world && cargo clippy -- -D warnings"
	docker compose run --rm dev bash -c "cd hello_world && cargo test"
