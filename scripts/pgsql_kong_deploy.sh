#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
PGDataDir=/data/mep/postgres
KongDataDir=/data/mep/kong

# clean docker 
docker rm -f kong-service
docker rm -f postgres-db

cat > ${CertDir}/init.sql << EOF
CREATE USER kong WITH PASSWORD 'kong';
CREATE USER mepauth WITH PASSWORD 'mepauth';
CREATE DATABASE mepauth;
REVOKE connect ON DATABASE kong FROM PUBLIC;
REVOKE connect ON DATABASE mepauth FROM PUBLIC;
GRANT ALL PRIVILEGES ON DATABASE kong TO admin;
GRANT ALL PRIVILEGES ON DATABASE mepauth TO admin;
GRANT ALL PRIVILEGES ON DATABASE kong TO kong;
GRANT ALL PRIVILEGES ON DATABASE mepauth TO mepauth;
GRANT connect ON DATABASE kong TO kong;
GRANT connect ON DATABASE mepauth TO mepauth;
ALTER DATABASE template0 is_template false;
ALTER DATABASE template1 is_template false;
DROP DATABASE template0;
DROP DATABASE template1;
EOF

chown eguser:eggroup ${CertDir}/init.sql
chmod 600 ${CertDir}/init.sql

# create mep-net network
docker network create mep-net

# run postgres db
docker run -d --name postgres-db \
                --user=166:166 \
                --network=mep-net \
                -p 5432:5432 \
                -e "POSTGRES_USER=admin" \
                -e "POSTGRES_DB=kong" \
                -e "POSTGRES_PASSWORD=admin" \
                -e "PGDATA=/var/lib/postgresql/data/pgdata" \
                -v "${PGDataDir}:/var/lib/postgresql/data" \
                -v "${CertDir}/mepserver_tls.crt:/var/lib/postgresql/data/server.crt" \
                -v "${CertDir}/mepserver_tls.key:/var/lib/postgresql/data/server.key" \
                -v "${CertDir}/init.sql:/docker-entrypoint-initdb.d/init.sql" \
                postgres:12.2 \
                -c ssl=on \
                -c ssl_cert_file=/var/lib/postgresql/data/server.crt \
                -c ssl_key_file=/var/lib/postgresql/data/server.key

## modify owner and mode of soft link
chown eguser:eggroup /data/mep/postgres/server.crt
chown eguser:eggroup /data/mep/postgres/server.key
chmod 600 /data/mep/postgres/server.crt
chmod 600 /data/mep/postgres/server.key

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
    -v ${CertDir}/mepserver_tls.crt:/var/lib/kong/data/kong.crt \
    -v ${CertDir}/mepserver_tls.key:/var/lib/kong/data/kong.key \
    -v ${CertDir}/ca.crt:/var/lib/kong/data/ca.crt \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=kong" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8444 ssl" \
    -e "KONG_PG_SSL=on" \
    -e "KONG_PG_SSL_VERIFY=on" \
    -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=/var/lib/kong/data/ca.crt" \
    -e "KONG_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_ADMIN_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_ADMIN_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_PREFIX=/var/lib/kong/data/kongdata" \
    -v "${KongDataDir}:/var/lib/kong/data" \
    -p 8443:8443 \
    -p 8444:8444 \
    kong:1.5.1-alpine

## modify owner and mode of soft link
chown eguser:eggroup /data/mep/kong/ca.crt
chown eguser:eggroup /data/mep/kong/kong.crt
chown eguser:eggroup /data/mep/kong/kong.key
chmod 600 /data/mep/kong/ca.crt
chmod 600 /data/mep/kong/kong.crt
chmod 600 /data/mep/kong/kong.key

# check docker status
docker ps -a |grep -E '(postgres-db|kong-service)'
