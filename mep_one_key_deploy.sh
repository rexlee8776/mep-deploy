#!/bin/bash

set -x

groupadd -r -g 166 eggroup

useradd -r -g 166 -u 166 eguser

usermod -aG docker eguser

./clean_all.sh

./generate_cert.sh

./pgsql_kong_deploy.sh

./mepauth_deploy.sh -u kong -p kong

./mepserver_deploy.sh

./check_env_status.sh