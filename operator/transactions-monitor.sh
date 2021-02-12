#!/bin/bash -eEu

set -o pipefail

COMPOSE_FILE=/opt/freeton-toolbox/tonos-cli/docker-compose.yml
KEYS_FILE=/opt/freeton-toolbox/.secrets/deploy.keys.json # IMPORTANT: make sure it exists
MSIG_ADDR='-1:...' # IMPORTANT: write validator's wallet address here
SERVICE=tonos-cli-dev

function getTransactions() {
    if [ -z $1 ]; then
        echo 'usage: getTransactions <addr>'
        return 1
    fi

    docker-compose -f "$COMPOSE_FILE" run -T --rm \
        $SERVICE \
        run $1 getTransactions '{}'
}

function confirmTransaction() {
    if [ -z $1 ] || [ -z $2 ]; then
        echo 'usage: confirmTransaction <addr> <id>'
        return 1
    fi

    ARGS=$(printf '{"transactionId":"%s"}' $2)

    docker-compose -f "$COMPOSE_FILE" run -T --rm \
        -v $KEYS_FILE:/opt/tonos-cli/deploy.keys.json:ro \
        $SERVICE \
        call $1 confirmTransaction "$ARGS"
}

function getConfig() {
    if [ -z $1 ]; then
        echo 'usage: getConfig <index>'
        return 1
    fi

    docker-compose -f "$COMPOSE_FILE" run -T --rm \
        $SERVICE \
        getconfig $1
}

function getElectorAddr() {
    printf -- '-1:%s' $(getConfig 1 | perl -ne '/Config p1: "([[:xdigit:]]+)"/ && print $1')
}

function confirmElectionTxs() {
    if [ -z $1 ]; then
        echo 'usage: confirmTransaction <addr>'
        return 1
    fi

    JQ_FILTER="$(printf '.transactions[] | select(.dest == "%s") | .id' $(getElectorAddr))"

    getTransactions $1 \
        | perl -pe 'chomp' \
        | perl -ne '/Result: (\{.*\})/ && print $1' \
        | jq -r "$JQ_FILTER" \
        | while IFS= read -r ID; do
            if [[ $ID =~ ^[[:digit:]]+$ ]]; then
                confirmTransaction $1 $ID
            fi
        done
}

confirmElectionTxs $MSIG_ADDR
