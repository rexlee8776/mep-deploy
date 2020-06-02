#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}

# clean docker 
docker rm -f kong-service
docker rm -f postgres-db

# create mep-net network
docker network create mep-net

cp  ${CertDir}/mepserver_tls.key ${CertDir}/server.key
cp ${CertDir}/mepserver_tls.crt ${CertDir}/server.crt

chown 999:999 ${CertDir}/server.key
chmod 600 ${CertDir}/server.key
chown 999:999 ${CertDir}/server.crt
chmod 600 ${CertDir}/server.crt

# run postgres db
docker run -d --name postgres-db \
                -p 5432:5432 \
                --network=mep-net \
                -e "POSTGRES_USER=kong" \
                -e "POSTGRES_DB=kong" \
                -e "POSTGRES_PASSWORD=kong" \
                -v "/tmp/mepserver/server.crt:/var/lib/postgresql/server.crt:ro" \
                -v "/tmp/mepserver/server.key:/var/lib/postgresql/server.key:ro" \
                postgres:12.2 \
                -c ssl=on \
                -c ssl_cert_file=/var/lib/postgresql/server.crt \
                -c ssl_key_file=/var/lib/postgresql/server.key
# inital postgres db
sleep 5
docker run --rm \
    --link postgres-db:postgres-db \
    --network=mep-net \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    kong:1.5.1-alpine kong migrations bootstrap

# run kong service
sleep 5
docker run -d --name kong-service \
    --link postgres-db:postgres-db \
    --network=mep-net \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong:1.5.1-alpine

# check docker status
docker ps -a |grep -E '(postgres-db|kong-service)'
