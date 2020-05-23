#!/bin/bash

COMPOSE_FILE=/opt/freeton-toolbox/validator/docker-compose.yml

docker-compose -f "$COMPOSE_FILE" kill -s SIGTERM freeton-validator-dev
docker-compose -f "$COMPOSE_FILE" up -d freeton-validator-dev

