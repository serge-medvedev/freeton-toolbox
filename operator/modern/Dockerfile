FROM rust:1.49.0-buster

WORKDIR /usr/src

RUN apt-get update && apt-get install -y clang \
    && git clone --recurse-submodules https://github.com/tonlabs/ton-labs-node-tools.git \
    && cd ton-labs-node-tools \
    && cargo update \
    && cargo build --release

FROM debian:buster-slim

COPY --from=0 \
    /usr/src/ton-labs-node-tools/target/release/console \
    /usr/src/ton-labs-node-tools/target/release/zerostate \
    /usr/src/ton-labs-node-tools/target/release/gendht \
    /usr/src/ton-labs-node-tools/target/release/keygen \
    /usr/src/ton-labs-node-tools/target/release/dhtscan \
    /usr/src/ton-labs-node-tools/target/release/print \
    /usr/local/bin/

RUN apt-get update && apt-get install -y ca-certificates libssl1.1

