#!/bin/bash

set +o history
set +x
source scripts/mep_vars.sh
set -x

rm -rf ${PG_DATA_DIR}/pgdata/*
rm -rf ${KONG_DATA_DIR}/kongdata/*

docker rm -f mepauth
docker rm -f kong-service
docker rm -f postgres-db
docker rm -f mepserver

scripts/mep_pre_deploy.sh

scripts/mepserver_deploy.sh

scripts/pgsql_kong_deploy.sh

sleep 5
scripts/mepauth_deploy.sh -u mepauth -p ${PG_MEPAUTH_PW} -jwt ${JWT_PW} -key ${KEY_COMPONENT} -appInsId ${APP_INST_ID} -ak ${ACCESS_KEY} -sk ${SECRET_KEY}

scripts/check_env_status.sh
set -o history
