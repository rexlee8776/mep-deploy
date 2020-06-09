#!/bin/bash

set -x

./clean_all.sh

scripts/mep_pre_deploy.sh

scripts/generate_cert.sh

scripts/mepserver_deploy.sh

scripts/pgsql_kong_deploy.sh

sleep 5
scripts/mepauth_deploy.sh -u mepauth -p te9Fmv%qaq -jwt te9Fmv%qaq

scripts/check_env_status.sh
