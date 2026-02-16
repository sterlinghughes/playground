FROM rust:slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY Cargo.toml ./
COPY proto/ proto/
COPY hello-server/ hello-server/
COPY hello-client/ hello-client/

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/target/release/hello-server /usr/local/bin/
COPY --from=builder /build/target/release/hello-client /usr/local/bin/

EXPOSE 50051

CMD ["hello-server"]
