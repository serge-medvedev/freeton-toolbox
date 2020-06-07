#!/bin/bash

cd /opt/freeton-toolbox/validator

docker-compose exec -T freeton-validator-dev ./getstats.sh

