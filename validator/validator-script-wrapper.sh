#!/bin/bash

#
# Usage: elections-notifier.sh \
#     <stake size in tokens> \
#     <comma-separated list of mail recipients>
#

COMPOSE_FILE="/opt/freeton-toolbox/validator/docker-compose.yml"
RECIPIENTS="$1"
STAKE=${2:-10001}
OUTPUT="$(docker-compose -f "$COMPOSE_FILE" exec -T freeton-validator-dev bash -eE ./validator_msig.sh $STAKE)"

echo "$OUTPUT"

if [ -z "$RECIPIENTS" ]; then
    echo "No mail recipients specified - no mail will be sent"
    exit 0
fi

if [ ! -z "$(echo "$OUTPUT" | awk '/"transId": "0x([[:xdigit:]]+)"/')" ]; then
    printf "To: Dear FreeTON Validator\nSubject: Transaction Confirmation Request\n\nThe latest validator script run output:\n\n%s\n" "$OUTPUT" | \
        msmtp -a default "$RECIPIENTS"
fi

