#!/bin/bash

set -x

#initial variables
source scripts/mep_vars.sh

./clean_all.sh

scripts/mep_pre_deploy.sh

scripts/generate_cert.sh

scripts/mepserver_deploy.sh

scripts/pgsql_kong_deploy.sh

sleep 5
scripts/mepauth_deploy.sh -u mepauth -p ${PG_MEPAUTH_PW} -jwt ${JWT_PW}

scripts/check_env_status.sh
