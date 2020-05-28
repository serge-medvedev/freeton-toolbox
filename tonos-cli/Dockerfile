FROM rust

ARG TONOS_CLI_VERSION=v0.1.6-rc

WORKDIR /opt/tonos-cli

RUN git clone https://github.com/tonlabs/ton-labs-contracts.git

RUN cargo install \
    --git https://github.com/tonlabs/tonos-cli.git \
    --tag $TONOS_CLI_VERSION

RUN ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json . \
    && ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc . \
    && ln -sf ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.abi.json . \
    && ln -sf ton-labs-contracts/solidity/setcodemultisig/SetcodeMultisigWallet.tvc .

ENTRYPOINT ["tonos-cli"]
