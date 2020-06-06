#!/bin/bash -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

if [[ "${ADNL_PORT}" =~ ^[0-9]+$ ]]; then
    sed -i "s/ADNL_PORT=\".*\"/ADNL_PORT=\"${ADNL_PORT}\"/g" "${SCRIPT_DIR}/env.sh"
fi

. "${SCRIPT_DIR}/env.sh"

function run_validator_engine() {
    . "${SCRIPT_DIR}/env.sh"

    "${TON_BUILD_DIR}/validator-engine/validator-engine" \
        --global-config "${TON_WORK_DIR}/etc/ton-global.config.json" \
        --db "${TON_WORK_DIR}/db" \
        --threads "${THREADS:-7}" 2>&1
}

FASTSYNC_LOG=$(mktemp)

function wait_for_sync() {
    while sleep 1m; do
        if fgrep --quiet 'completed sync.' "${FASTSYNC_LOG}"; then
            break
        fi
    done
}

if [ ! -d "${TON_WORK_DIR}/db" ]; then
    FREETON_FASTSYNC_DIR=/tmp/freeton-fastsync/work

    sed -i "s|TON_WORK_DIR=\".*\"|TON_WORK_DIR=\"${FREETON_FASTSYNC_DIR}\"|g" "${SCRIPT_DIR}/env.sh"

    "${SCRIPT_DIR}/setup.sh" 2>&1

    echo "INFO: start TON node [fastsync]..."

    run_validator_engine | tee "${FASTSYNC_LOG}" &

    FASTSYNC_PID=$!

    wait_for_sync

    kill "${FASTSYNC_PID}" 2>/dev/null
    wait "${FASTSYNC_PID}"

    sudo rsync --archive --remove-source-files "${FREETON_FASTSYNC_DIR}" "${TON_WORK_DIR}"
    sudo chown -R freeton:freeton "${TON_WORK_DIR}"

    sed -i "s|TON_WORK_DIR=\".*\"|TON_WORK_DIR=\"${TON_WORK_DIR}\"|g" "${SCRIPT_DIR}/env.sh"

    echo "INFO: fastsync is done - restarting..."
else
    echo "INFO: start TON node..."
fi

run_validator_engine

