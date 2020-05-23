#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

TIME_DIFF="$(./check_node_sync_status.sh | grep -oP 'TIME_DIFF = -\K(\d+)')"
HOST_IP="$(ip route | awk '/default/ {print $3}')"
STATSD_PORT=8125

if ! [ -z "$TIME_DIFF" ]; then
    printf "freeton.validator.timediff:%s|g" "$TIME_DIFF" | nc -q 0 $HOST_IP $STATSD_PORT
fi

printf "freeton.validator.dbsize:%s|g" "$(du -s "$TON_WORK_DIR/db" | awk '{print $1}')" | nc -q 0 $HOST_IP $STATSD_PORT
