FROM rust

ARG TONOS_CLI_VERSION=v0.1.27

WORKDIR /opt/tonos-cli

RUN cargo install \
    --git https://github.com/tonlabs/tonos-cli.git \
    --tag $TONOS_CLI_VERSION

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
    && ln -sf ton-labs-contracts/solidity/depool/DePoolProxy.tvc .

ENTRYPOINT ["tonos-cli"]
