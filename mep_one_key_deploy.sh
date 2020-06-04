#!/bin/bash

set -x

./clean_all.sh

./generate_cert.sh

./pgsql_kong_deploy.sh

./mepauth_deploy.sh -u kong -p kong

./mepserver_deploy.sh

./check_env_status.sh