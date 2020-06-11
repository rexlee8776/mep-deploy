#!/bin/bash

set +o history
set -x

docker rm -f mepauth
docker rm -f kong-service
docker rm -f postgres-db
docker rm -f mepserver

scripts/mep_pre_deploy.sh

scripts/mepserver_deploy.sh

scripts/pgsql_kong_deploy.sh

sleep 5
scripts/mepauth_deploy.sh -u mepauth -p mepauth -jwt te9Fmv%qaq

scripts/check_env_status.sh
set -o history
