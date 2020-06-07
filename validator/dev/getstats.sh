#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

HOST_IP="$(ip route | awk '/default/ {print $3}')"
STATSD_PORT=8125

TIME_DIFF="$(./check_node_sync_status.sh | grep -oP 'TIME_DIFF = -\K(\d+)')"

if [ ! -z "$TIME_DIFF" ]; then
    printf "freeton.validator.timediff:%s|g" "$TIME_DIFF" | nc -q 0 $HOST_IP $STATSD_PORT
fi

printf "freeton.validator.dbsize:%s|g" "$(du -s "$TON_WORK_DIR/db" | awk '{print $1}')" | nc -q 0 $HOST_IP $STATSD_PORT

ELECTOR_ADDR_BASE64="$(cat "$KEYS_DIR/elections/elector-addr-base64")"
LC_OUTPUT=$($TON_BUILD_DIR/lite-client/lite-client \
    -a 127.0.0.1:3031 \
    -p "$KEYS_DIR/liteserver.pub" \
    -rc "$(printf "runmethod %s active_election_id" "$ELECTOR_ADDR_BASE64")" \
    -rc "$(printf "runmethod %s past_election_ids" "$ELECTOR_ADDR_BASE64")" \
    -rc "quit" 2>&1)
ACTIVE_ELECTION_ID=$(echo "$LC_OUTPUT" | perl -ne '/^result:\s*\[\s*(\d+)\s*\]\s*$/ && print $1')
PAST_ELECTION_ID=$(echo "$LC_OUTPUT" | perl -ne '/^result:\s*\[\s*\((\d+\s*)+\)\s*\]\s*$/ && print $1')
PAST_ELECTION_ID_FILE="/tmp/freeton-validator-stats-$PAST_ELECTION_ID"

if [ "$ACTIVE_ELECTION_ID" -eq 0 ] && [ ! -f "$PAST_ELECTION_ID_FILE" ]; then
    LC_OUTPUT="$($TON_BUILD_DIR/lite-client/lite-client \
        -a 127.0.0.1:3031 \
        -p $KEYS_DIR/liteserver.pub \
        -rc "getconfig 34" \
        -rc "getconfig 36" \
        -rc "$(printf "runmethod %s past_elections" "$ELECTOR_ADDR_BASE64")" \
        -rc "quit" 2>&1)"
    TOTAL_WEIGHT=$(echo "$LC_OUTPUT" | perl -ne '/^\s*cur_validators:.*total_weight:(\d+)$/ && print $1')
    VALIDATOR_PUBKEY="$(cat "$KEYS_DIR/elections/$VALIDATOR_NAME-request-dump2" 2>&1 | \
        perl -ne '/with validator public key ([A-F0-9]+)/ && print $1')"
    WEIGHT=$(echo "$LC_OUTPUT" | \
        perl -ne "$(printf '/^\s*public_key:\(ed25519_pubkey pubkey:x%s\) weight:(\d+).*$/i && print $1' "$VALIDATOR_PUBKEY")")
    TOTAL_STAKE=$(echo "$LC_OUTPUT" | \
        perl -ne '/^result:\s*\[\s*\((?>\[\d+ \d+ \d+ \d+ [\{\}\(\)A-F0-9]+ (\d+) \d+ [\{\}\(\)A-F0-9]+\]\s*)*\)\s*\]\s*$/ && print $1')
    WEIGHT_RATIO=$(echo "${WEIGHT:-0} $TOTAL_WEIGHT" | awk '{print $1/$2}')
    STAKE=$(echo "$TOTAL_STAKE $WEIGHT_RATIO" | awk '{print $1*$2}')

    printf '%s %s\n' $WEIGHT_RATIO $STAKE > "$PAST_ELECTION_ID_FILE"

    cat "$PAST_ELECTION_ID_FILE"
fi

read -r WEIGHT_RATIO STAKE <<< $(cat "$PAST_ELECTION_ID_FILE" || echo '0 0')

if ! { [ -z $WEIGHT_RATIO ] || [ -z $STAKE ]; }; then
    printf "freeton.validator.weight:%s|g" $WEIGHT_RATIO | nc -q 0 $HOST_IP $STATSD_PORT
    printf "freeton.validator.stake:%s|g" $STAKE | nc -q 0 $HOST_IP $STATSD_PORT
fi
