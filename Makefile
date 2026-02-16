.PHONY: test lint ci \
       hello_world \
       hello_service hello_service_test hello_service_lint hello_service_server hello_service_client \
       hello_service_deploy hello_service_undeploy hello_service_status hello_service_port_forward \
       hello_service_integration_test \
       kind_create kind_delete kind_build kind_load kind_deploy kind_undeploy \
       kind_port_forward kind_status kind_integration_test

CLUSTER_NAME    ?= playground
SERVICE_NAME    ?= hello-service
SERVICE_DIR     ?= hello_service
SERVICE_PORT    ?= 50051
SERVICE_TEST_CMD ?= cargo run --release --bin hello-client -- --addr http://127.0.0.1:$(SERVICE_PORT) --name Integration

test:
	cargo test --workspace

lint:
	cargo clippy --workspace -- -D warnings

hello_world:
	cargo run --release -p hello_world

hello_service:
	cargo build --release -p hello-server -p hello-client

hello_service_test:
	cargo test -p hello-server -p hello-client

hello_service_lint:
	cargo clippy -p hello-server -p hello-client -- -D warnings

hello_service_server:
	PORT=$(SERVICE_PORT) cargo run --release --bin hello-server

hello_service_client:
	cargo run --release --bin hello-client -- $(ARGS)

hello_service_deploy:
	$(MAKE) kind_deploy SERVICE_NAME=hello-service SERVICE_DIR=hello_service SERVICE_PORT=50051

hello_service_undeploy:
	$(MAKE) kind_undeploy SERVICE_NAME=hello-service

hello_service_status:
	$(MAKE) kind_status SERVICE_NAME=hello-service

hello_service_port_forward:
	$(MAKE) kind_port_forward SERVICE_NAME=hello-service SERVICE_PORT=50051

hello_service_integration_test:
	$(MAKE) kind_integration_test SERVICE_NAME=hello-service SERVICE_DIR=hello_service SERVICE_PORT=50051 \
		SERVICE_TEST_CMD="cargo run --release --bin hello-client -- --addr http://127.0.0.1:50051 --name Integration"

ci:
	cargo clippy --workspace -- -D warnings
	cargo test --workspace

# kind (local Kubernetes) targets

kind_create:
	kind create cluster --name $(CLUSTER_NAME)

kind_delete:
	kind delete cluster --name $(CLUSTER_NAME)

kind_build:
	docker build -t $(SERVICE_NAME):latest $(SERVICE_DIR)/

kind_load:
	kind load docker-image $(SERVICE_NAME):latest --name $(CLUSTER_NAME)

define KUSTOMIZE_OVERLAY
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../base
patches:
  - target:
      kind: Deployment
      name: $(SERVICE_NAME)
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env/0/value
        value: "$(SERVICE_PORT)"
      - op: replace
        path: /spec/template/spec/containers/0/ports/0/containerPort
        value: $(SERVICE_PORT)
  - target:
      kind: Service
      name: $(SERVICE_NAME)
    patch: |-
      - op: replace
        path: /spec/ports/0/port
        value: $(SERVICE_PORT)
endef
export KUSTOMIZE_OVERLAY

kind_deploy: kind_build kind_load
	@mkdir -p opt/k8s/_deploy
	@echo "$$KUSTOMIZE_OVERLAY" > opt/k8s/_deploy/kustomization.yaml
	kubectl apply -k opt/k8s/_deploy

kind_undeploy:
	kubectl delete -k opt/k8s/base

kind_port_forward:
	kubectl port-forward svc/$(SERVICE_NAME) $(SERVICE_PORT):$(SERVICE_PORT)

kind_status:
	kubectl get pods -l app=$(SERVICE_NAME)
	kubectl get svc $(SERVICE_NAME)

kind_integration_test: kind_deploy
	@echo "Waiting for $(SERVICE_NAME) pod to be ready..."
	kubectl wait --for=condition=ready pod -l app=$(SERVICE_NAME) --timeout=120s
	kubectl port-forward --address 0.0.0.0 svc/$(SERVICE_NAME) $(SERVICE_PORT):$(SERVICE_PORT) &
	@sleep 3
	cd $(SERVICE_DIR) && $(SERVICE_TEST_CMD) || { kill %1 2>/dev/null; exit 1; }
	@kill %1 2>/dev/null || true
	@echo "Integration test passed!"
