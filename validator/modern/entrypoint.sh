#!/bin/bash -eE

CONFIGS_DIR='/etc/ton'
LOGS_DIR='/var/log/ton'

mkdir -p "$CONFIGS_DIR" "$LOGS_DIR"

function configure() {
    curl -sS 'https://raw.githubusercontent.com/tonlabs/rustnet.ton.dev/main/docker-compose/ton-node/configs/log_cfg.yml' -o "$CONFIGS_DIR/log_cfg.yml"

    sed -i "s|/ton-node/logs|$LOGS_DIR|g" "$CONFIGS_DIR/log_cfg.yml"

    curl -sS 'https://raw.githubusercontent.com/tonlabs/rustnet.ton.dev/main/docker-compose/ton-node/configs/default_config.json' -o "$CONFIGS_DIR/default_config.json"

    MODIFIED=$(mktemp)
    jq --argjson cport "$CONSOLE_PORT" '.control_server_port = $cport' "$CONFIGS_DIR/default_config.json" > "$MODIFIED" \
        && mv "$MODIFIED" "$CONFIGS_DIR/default_config.json"

    curl -sS 'https://raw.githubusercontent.com/tonlabs/rustnet.ton.dev/main/configs/ton-global.config.json' -o "$CONFIGS_DIR/ton-global.config.json"
}

function run() {
    ARGS=( '--configs' "$CONFIGS_DIR" )

    [ -n "$CONSOLE_KEY" ] && ARGS+=( '--ckey' "$CONSOLE_KEY" )

    exec ton_node "${ARGS[@]}" 2>&1
}

configure && run

