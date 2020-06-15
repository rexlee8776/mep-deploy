#!/bin/bash


set +o history
#initial variables
set +x
source scripts/mep_vars.sh
set -x

./clean_all.sh

scripts/mep_pre_deploy.sh

scripts/generate_cert.sh

scripts/mepserver_deploy.sh

scripts/pgsql_kong_deploy.sh

sleep 5

scripts/mepauth_deploy.sh -u mepauth -p ${PG_MEPAUTH_PW} -jwt ${JWT_PW} -key ${KEY_COMPONENT} -appInsId ${APP_INST_ID} -ak ${ACCESS_KEY} -sk ${SECRET_KEY}

scripts/check_env_status.sh
set -o history
