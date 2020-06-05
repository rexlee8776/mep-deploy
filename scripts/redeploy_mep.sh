#!/bin/bash

set -x

scripts/pgsql_kong_deploy.sh

scripts/mepauth_deploy.sh -u mepauth -p mepauth -jwt te9Fmv%qaq

scripts/mepserver_deploy.sh

scripts/check_env_status.sh
