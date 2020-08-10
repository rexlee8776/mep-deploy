#!/bin/bash

set +o history
# initial variable
set +x
source scripts/mep_vars.sh
set -x

echo "CREATE USER kong WITH PASSWORD '${PG_KONG_PW}';" > ${MEP_CERTS_DIR}/init.sql

cat >> ${MEP_CERTS_DIR}/init.sql << EOF
REVOKE connect ON DATABASE kong FROM PUBLIC;
GRANT ALL PRIVILEGES ON DATABASE kong TO admin;
GRANT ALL PRIVILEGES ON DATABASE kong TO kong;
GRANT connect ON DATABASE kong TO kong;
ALTER DATABASE template0 is_template false;
ALTER DATABASE template1 is_template false;
DROP DATABASE template0;
DROP DATABASE template1;
DROP DATABASE postgres;
EOF

chown eguser:eggroup ${MEP_CERTS_DIR}/init.sql
chmod 600 ${MEP_CERTS_DIR}/init.sql

# run postgres db
docker run -d --name postgres-db \
                --user=166:166 \
                --network=mep-net \
                --cap-drop All \
                -e "POSTGRES_USER=admin" \
                -e "POSTGRES_DB=kong" \
                -e "POSTGRES_PASSWORD=${PG_ADMIN_PW}" \
                -e "POSTGRES_INITDB_ARGS=--auth-local=password" \
                -e "PGDATA=/var/lib/postgresql/data/pgdata" \
                -v "${PG_DATA_DIR}:/var/lib/postgresql/data" \
                -v "${MEP_CERTS_DIR}/mepserver_tls.crt:/var/lib/postgresql/data/server.crt:ro" \
                -v "${MEP_CERTS_DIR}/mepserver_tls.key:/var/lib/postgresql/data/server.key:ro" \
                -v "${MEP_CERTS_DIR}/init.sql:/docker-entrypoint-initdb.d/init.sql:ro" \
                "$REGISTRY_URL"postgres:12.3 \
                -c ssl=on \
                -c ssl_cert_file=/var/lib/postgresql/data/server.crt \
                -c ssl_key_file=/var/lib/postgresql/data/server.key

## modify owner and mode of soft link
chown eguser:eggroup /data/thirdparty/postgres/server.crt
chown eguser:eggroup /data/thirdparty/postgres/server.key
chmod 600 /data/thirdparty/postgres/server.crt
chmod 600 /data/thirdparty/postgres/server.key

# inital postgres db
sleep 5
docker run --rm \
    --user=166:166 \
    --cap-drop All \
    --link postgres-db:postgres-db \
    --network=mep-net \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=${PG_KONG_PW}" \
    "$REGISTRY_URL"kong:2.0.4-alpine kong migrations bootstrap

# run kong service
sleep 5

## setup plugin and kong.conf
cp -r kong-conf /tmp/kong-conf
chown -R eguser:eggroup /tmp/kong-conf
chmod 700 /tmp/kong-conf

## run kong docker
docker run -d --name kong-service \
    --user=166:166 \
    --cap-drop All \
    --link postgres-db:postgres-db \
    --link mepserver:mepserver \
    --link mepauth:mepauth \
    --network=mep-net \
    -v ${MEP_CERTS_DIR}/mepserver_tls.crt:/var/lib/kong/data/kong.crt:ro \
    -v ${MEP_CERTS_DIR}/mepserver_tls.key:/var/lib/kong/data/kong.key:ro \
    -v ${MEP_CERTS_DIR}/ca.crt:/var/lib/kong/data/ca.crt:ro \
    -v ${KONG_PLUGIN_PATH}:/usr/local/share/lua/5.1/kong/plugins/appid-header:ro \
    -v ${KONG_CONF_PATH}:/etc/kong/kong.conf:ro \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=postgres-db" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=${PG_KONG_PW}" \
    -e "KONG_PROXY_ACCESS_LOG=/tmp/access.log" \
    -e "KONG_ADMIN_ACCESS_LOG=/tmp/admin-access.log" \
    -e "KONG_PROXY_ERROR_LOG=/tmp/proxy.log" \
    -e "KONG_ADMIN_ERROR_LOG=/tmp/proxy-admin.log" \
    -e "KONG_PG_SSL=on" \
    -e "KONG_PG_SSL_VERIFY=on" \
    -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=/var/lib/kong/data/ca.crt" \
    -e "KONG_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_ADMIN_SSL_CERT=/var/lib/kong/data/kong.crt" \
    -e "KONG_ADMIN_SSL_CERT_KEY=/var/lib/kong/data/kong.key" \
    -e "KONG_PREFIX=/var/lib/kong/data/kongdata" \
    -e "KONG_HEADERS=off" \
    -e "KONG_SSL_CIPHER_SUITE=custom" \
    -e "KONG_SSL_CIPHERS=ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384" \
    -e "KONG_NGINX_HTTP_SSL_PROTOCOLS=TLSv1.2 TLSv1.3" \
    -e "KONG_NGINX_HTTP_SSL_PREFER_SERVER_CIPHERS=on" \
    -v "${KONG_DATA_DIR}:/var/lib/kong/data" \
    -p $MEP_IP:8443:8443 \
    "$REGISTRY_URL"kong:2.0.4-alpine /bin/sh -c 'export ADDR=`hostname`;export KONG_ADMIN_LISTEN="$ADDR:8444 ssl";export KONG_PROXY_LISTEN="$ADDR:8443 ssl http2";./docker-entrypoint.sh kong docker-start'

## modify owner and mode of soft link
chown eguser:eggroup ${KONG_DATA_DIR}/ca.crt
chown eguser:eggroup ${KONG_DATA_DIR}/kong.crt
chown eguser:eggroup ${KONG_DATA_DIR}/kong.key
chmod 600 ${KONG_DATA_DIR}/ca.crt
chmod 600 ${KONG_DATA_DIR}/kong.crt
chmod 600 ${KONG_DATA_DIR}/kong.key

# remove init.sql
rm ${MEP_CERTS_DIR}/init.sql

# check docker status
docker ps -a |grep -E '(postgres-db|kong-service)'
set -o history
