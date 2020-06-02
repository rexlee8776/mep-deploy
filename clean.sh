#!/bin/bash
# docker rm -f mepserver
docker rm -f mepauth
docker rm -f kong-service
docker rm -f postgres-db
docker network rm mep-net
