#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
PGDataDir=/data/mep/postgres
KongDataDir=/data/mep/kong


cat > ${CertDir}/init.sql << EOF
CREATE USER kong WITH PASSWORD 'te9Fmv%qaq';
CREATE USER mepauth WITH PASSWORD 'te9Fmv%qaq';
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

# run postgres db
docker run -d --name postgres-db \
                --user=166:166 \
                --network=mep-net \
                -e "POSTGRES_USER=admin" \
                -e "POSTGRES_DB=kong" \
                -e "POSTGRES_PASSWORD=te9Fmv%qaq" \
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
    -e "KONG_PG_PASSWORD=te9Fmv%qaq" \
    kong:1.5.1-alpine kong migrations bootstrap

# run kong service
sleep 5

## setup plugin and kong.conf
cp -r kong-conf /tmp/kong-conf
chown -R eguser:eggroup /tmp/kong-conf
chmod 700 /tmp/kong-conf

KONG_PLUGIN_PATH=/tmp/kong-conf/appid-header
KONG_CONF_PATH=/tmp/kong-conf/kong.conf

## run kong docker
docker run -d --name kong-service \
    --user=166:166 \
    --link postgres-db:postgres-db \
    --link mepserver:mepserver \
    --network=mep-net \
    -v ${CertDir}/mepserver_tls.crt:/var/lib/kong/data/kong.crt \
    -v ${CertDir}/mepserver_tls.key:/var/lib/kong/data/kong.key \
    -v ${CertDir}/ca.crt:/var/lib/kong/data/ca.crt \
    -v ${KONG_PLUGIN_PATH}:/usr/local/share/lua/5.1/kong/plugins/appid-header \
    -v ${KONG_CONF_PATH}:/etc/kong/kong.conf \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=te9Fmv%qaq" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_PG_SSL=on" \
    -e "KONG_PG_SSL_VERIFY=on" \
    -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=/var/lib/kong/data/ca.crt" \
    -e "KONG_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_ADMIN_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_ADMIN_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_PREFIX=/var/lib/kong/data/kongdata" \
    -e "KONG_SSL_CIPHER_SUITE=custom" \
    -e "KONG_SSL_CIPHERS=ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384" \
    -e "KONG_NGINX_HTTP_SSL_PROTOCOLS=TLSv1.2 TLSv1.3" \
    -e "KONG_NGINX_HTTP_SSL_PREFER_SERVER_CIPHERS=on" \
    -v "${KongDataDir}:/var/lib/kong/data" \
    -p 8443:8443 \
    -p 8444:8444 \
    kong:1.5.1-alpine /bin/sh -c 'export ADDR=`hostname`;export KONG_ADMIN_LISTEN="$ADDR:8444 ssl";export KONG_PROXY_LISTEN="$ADDR:8443 ssl http2";./docker-entrypoint.sh kong docker-start'

## modify owner and mode of soft link
chown eguser:eggroup /data/mep/kong/ca.crt
chown eguser:eggroup /data/mep/kong/kong.crt
chown eguser:eggroup /data/mep/kong/kong.key
chmod 600 /data/mep/kong/ca.crt
chmod 600 /data/mep/kong/kong.crt
chmod 600 /data/mep/kong/kong.key

# remove init.sql
rm ${CertDir}/init.sql

# check docker status
docker ps -a |grep -E '(postgres-db|kong-service)'
