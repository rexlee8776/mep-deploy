#!/bin/bash

set -x

./clean_all.sh

scripts/mep_pre_deploy.sh

scripts/generate_cert.sh

scripts/pgsql_kong_deploy.sh

sleep 5
scripts/mepauth_deploy.sh -u mepauth -p mepauth -jwt te9Fmv%qaq

scripts/mepserver_deploy.sh

scripts/check_env_status.sh
