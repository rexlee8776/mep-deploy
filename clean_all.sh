#!/bin/bash

docker rm -f mepserver
docker rm -f mepauth
docker rm -f kong-service
docker rm -f postgres-db
docker network rm mep-net

# clean user and directory

set -x

rm -rf /tmp/mepserver
rm -rf /data/mep
userdel eguser
groupdel eggroup
