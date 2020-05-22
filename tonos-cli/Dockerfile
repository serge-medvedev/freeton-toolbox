FROM rust

WORKDIR /opt/tonos-cli

RUN git clone https://github.com/tonlabs/ton-labs-contracts.git

RUN cargo install \
    --git https://github.com/tonlabs/tonos-cli.git \
    --tag v0.1.2

RUN ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json . \
    && ln -sf ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc .

ENTRYPOINT ["tonos-cli"]
