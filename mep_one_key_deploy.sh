#!/bin/bash

set -x

./clean_all.sh

./generate_cert.sh

./pgsql_kong_deploy.sh

./mepauth_deploy.sh

./mepserver_deploy.sh

./check_env_status.sh
