FROM rust:1.49.0-buster

ARG TONOS_CLI_VERSION=v0.5.0

WORKDIR /usr/src

RUN git clone https://github.com/tonlabs/tonos-cli.git \
    && cd tonos-cli \
    && cargo build --release

WORKDIR /opt/tonos-cli

RUN git clone https://github.com/tonlabs/ton-labs-contracts.git

RUN ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json . \
    && ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc . \
    && ln -sf ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.abi.json . \
    && ln -sf ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.tvc . \
    && ln -sf ton-labs-contracts/solidity/depool/DePool.abi.json . \
    && ln -sf ton-labs-contracts/solidity/depool/DePool.tvc . \
    && ln -sf ton-labs-contracts/solidity/depool/DePoolHelper.abi.json . \
    && ln -sf ton-labs-contracts/solidity/depool/DePoolHelper.tvc . \
    && ln -sf ton-labs-contracts/solidity/depool/DePoolProxy.abi.json . \
    && ln -sf ton-labs-contracts/solidity/depool/DePoolProxy.tvc . \
    && ln -sf ton-labs-contracts/solidity/contest/FreeTonContest.abi.json .

FROM debian:buster-slim

WORKDIR /opt/tonos-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl1.1 \
    ca-certificates

COPY --from=0 /usr/src/tonos-cli/target/release/tonos-cli /usr/local/bin/
COPY --from=0 /opt/tonos-cli /opt/tonos-cli

ENTRYPOINT ["tonos-cli"]

