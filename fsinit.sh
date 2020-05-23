#!/bin/bash

USERID=$1
GROUPID=$2

if [ -z $USERID ] || [ -z $GROUPID ]; then
	echo "usage: sudo $0 <uid> <gid>"
	exit 1
fi

### This creates the folder structure required.
mkdir -p \
	/opt/freeton-toolbox \
	/var/log/freeton-toolbox \
	/var/lib/influxdb \
	/var/lib/chronograf

git clone https://github.com/serge-medvedev/freeton-toolbox.git /opt/freeton-toolbox

chown -R $USERID:$GROUPID \
	/opt/freeton-toolbox \
	/var/log/freeton-toolbox
