#!/bin/bash

COMPOSE_FILE="/opt/freeton-toolbox/validator/docker-compose.yml"

docker-compose -f "$COMPOSE_FILE" exec -T freeton-validator-dev ./getstats.sh

