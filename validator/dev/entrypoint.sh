#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
. "${SCRIPT_DIR}/env.sh"
TON_WORK_BACKUP_DIR=/var/ton.backup/work

prep_term() {
    unset VALIDATOR_PID
    unset TERM_KILL_NEEDED
    trap handle_term TERM INT
}

handle_term() {
    echo "INFO: SIGTERM is caught!"
    if [ "${VALIDATOR_PID}" ]; then
        kill -TERM "${VALIDATOR_PID}" 2>/dev/null
    else
        TERM_KILL_NEEDED="yes"
    fi
}

wait_term() {
    VALIDATOR_PID=$!
    if [ "${TERM_KILL_NEEDED}" ]; then
        kill -TERM "${VALIDATOR_PID}" 2>/dev/null
    fi
    wait "${VALIDATOR_PID}"
    trap - TERM INT
    wait "${VALIDATOR_PID}"
}

if ! [ -d "${TON_WORK_DIR}/db" ]; then
    if [ -d "${TON_WORK_BACKUP_DIR}" ]; then
        sudo cp -a "${TON_WORK_BACKUP_DIR}" "$(dirname "${TON_WORK_DIR}")"
        sudo chown -R freeton:freeton "${TON_WORK_DIR}"
    else
        echo "INFO: setup TON node..."

        "${SCRIPT_DIR}/setup.sh" 2>&1
    fi
fi

echo "INFO: start TON node..."

set +e

prep_term

"${TON_BUILD_DIR}/validator-engine/validator-engine" \
    --global-config "${TON_WORK_DIR}/etc/ton-global.config.json" \
    --db "${TON_WORK_DIR}/db" \
    1>/dev/stdout 2>&1 &

wait_term

EXIT_CODE=$?

echo "validator-engine exited with code $EXIT_CODE"

rm -fr "${TON_WORK_BACKUP_DIR}"
rsync -au "${TON_WORK_DIR}" "$(dirname "${TON_WORK_BACKUP_DIR}")"
