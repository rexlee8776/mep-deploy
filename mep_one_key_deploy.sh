#!/bin/bash

set -x

./clean_all.sh

scripts/mep_pre_deploy.sh

scripts/generate_cert.sh

scripts/pgsql_kong_deploy.sh

scripts/mepauth_deploy.sh -u mepauth -p mepauth

scripts/mepserver_deploy.sh

scripts/check_env_status.sh
