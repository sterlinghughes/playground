FROM quay.io/centos/centos:stream10 AS builder

RUN dnf install -y dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && dnf install -y gcc gcc-c++ make protobuf-compiler \
    && dnf clean all \
    && rm -rf /var/cache/dnf

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain stable --profile minimal

WORKDIR /build
RUN printf '[workspace]\nmembers = ["hello-server", "hello-client"]\nresolver = "2"\n' > Cargo.toml
COPY proto/ proto/
COPY hello-server/ hello-server/
COPY hello-client/ hello-client/

RUN cargo build --release

FROM playground-base:latest

COPY --from=builder /build/target/release/hello-server /usr/local/bin/
COPY --from=builder /build/target/release/hello-client /usr/local/bin/

EXPOSE 50051

CMD ["hello-server"]
