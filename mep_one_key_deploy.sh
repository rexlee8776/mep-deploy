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

scripts/mepauth_deploy.sh

sleep 5

rm -f ${MEP_CONF_PATH}

scripts/check_env_status.sh
set -o history
