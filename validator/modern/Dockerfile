FROM rust:1.49.0-buster

WORKDIR /usr/src

ENV TON_LABS_NODE_COMMIT=master

RUN apt-get update && apt-get install -y clang \
    && git clone --recurse-submodules https://github.com/tonlabs/ton-labs-node.git \
    && cd ton-labs-node \
    && git checkout ${TON_LABS_NODE_COMMIT} \
    && sed -i 's/127\.0\.0\.1/0.0.0.0/g' src/config.rs \
    && cargo update \
    && cargo build --release

FROM debian:buster

COPY --from=0 \
    /usr/src/ton-labs-node/target/release/ton_node \
    /usr/local/bin/

RUN apt-get update && apt-get install -y \
    libssl1.1 \
    curl \
    jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh

