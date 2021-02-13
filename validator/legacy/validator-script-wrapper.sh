#!/bin/bash

#
# Usage: validator-script-wrapper.sh \
#     <stake size in tokens> \
#     <comma-separated list of mail recipients>
#

cd /opt/freeton-toolbox/validator

STAKE=${1:-10001}
RECIPIENTS="$2"
OUTPUT="$(docker-compose exec -T freeton-validator-dev bash -eE ./validator_msig.sh $STAKE)"

echo "$OUTPUT"

if [ ! -z "$RECIPIENTS" ] && [ ! -z "$(echo "$OUTPUT" | awk '/"transId": "0x([[:xdigit:]]+)"/')" ]; then
    printf "To: Dear FreeTON Validator\nSubject: Transaction Confirmation Request\n\nThe latest validator script run output:\n\n%s\n" "$OUTPUT" | \
        docker-compose -f "$COMPOSE_FILE" run -T --rm msmtp -a default "$RECIPIENTS"
fi
