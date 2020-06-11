#!/bin/bash

set +o history
# initial variables
set +x
source scripts/mep_vars.sh
set -x

docker rm -f mepserver
docker rm -f mepauth
docker rm -f kong-service
docker rm -f postgres-db
docker network rm mep-net

# clean user and directory
rm -rf ${KONG_DATA_DIR}
rm -rf ${PG_DATA_DIR}
rm -rf ${MEP_CERTS_DIR}

userdel eguser
groupdel eggroup
set -o history
