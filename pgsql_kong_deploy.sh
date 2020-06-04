#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
DataDir=/data/mep
# clean docker 
docker rm -f kong-service
docker rm -f postgres-db

# create mep-net network
docker network create mep-net

mkdir -p ${DataDir}
chown eguser:eggroup ${DataDir}
chmod 700 ${DataDir}

# run postgres db
docker run -d --name postgres-db \
                -p 5432:5432 \
                --user=166:166 \
                --network=mep-net \
                -e "POSTGRES_USER=kong" \
                -e "POSTGRES_DB=kong" \
                -e "POSTGRES_PASSWORD=kong" \
                -e "PGDATA=/var/lib/postgresql/data/pgdata" \
                -v "${DataDir}:/var/lib/postgresql/data" \
                -v "${CertDir}/mepserver_tls.crt:/var/lib/postgresql/server.crt" \
                -v "${CertDir}/mepserver_tls.key:/var/lib/postgresql/server.key" \
                postgres:12.2 \
                -c ssl=on \
                -c ssl_cert_file=/var/lib/postgresql/server.crt \
                -c ssl_key_file=/var/lib/postgresql/server.key
# inital postgres db
sleep 5
docker run --rm \
    --user=166:166 \
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
    --user=166:166 \
    --link postgres-db:postgres-db \
    --network=mep-net \
    -v ${CertDir}/ca.crt:/run/kongssl/ca.crt \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -e "KONG_PG_SSL=on" \
    -e "KONG_PG_SSL_VERIFY=on" \
    -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=/run/kongssl/ca.crt" \
    -e "KONG_PREFIX=/var/lib/kong/data/kongdata" \
    -v "${DataDir}:/var/lib/kong/data" \
    -p 8443:8443 \
    -p 8444:8444 \
    kong:1.5.1-alpine

# check docker status
docker ps -a |grep -E '(postgres-db|kong-service)'
