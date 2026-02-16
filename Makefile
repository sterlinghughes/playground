.PHONY: build shell up down ci

build:
	docker compose build

shell: up
	docker compose exec dev bash

up:
	docker compose up -d

down:
	docker compose down

ci:
	docker compose build
	docker compose run --rm dev bash -c "echo 'Health check: OK' && uname -a"
