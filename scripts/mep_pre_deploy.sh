#!/bin/bash

set +o history
# initial variables
set +x
source ./scripts/mep_vars.sh
set -x

# add eguser and eggroup
groupadd -r -g 166 eggroup
useradd -r -g 166 -u 166 eguser

# add eguser to docker group
usermod -aG docker eguser

# create postgres work dir
mkdir -p ${PG_DATA_DIR}
chown eguser:eggroup ${PG_DATA_DIR}
chmod 700 ${PG_DATA_DIR}

# create kong work dir
mkdir -p ${KONG_DATA_DIR}
chown eguser:eggroup ${KONG_DATA_DIR}
chmod 700 ${KONG_DATA_DIR}

# create mepauth keys dir
mkdir -p ${MEPAUTH_KEYS_DATA_DIR}
chown eguser:eggroup ${MEPAUTH_KEYS_DATA_DIR}
chmod 700 ${MEPAUTH_KEYS_DATA_DIR}

# create cert generation dir
mkdir -p ${MEP_CERTS_DIR}
chown eguser:eggroup ${MEP_CERTS_DIR}
chmod 700 ${MEP_CERTS_DIR}

# create mep network
docker network create mep-net
set -o history
