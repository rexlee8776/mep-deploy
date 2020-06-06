#!/bin/bash

set -x

KONG_HOST=edgegallery.org
KONG_ADMIN_PORT=8444
MEPSERVER_HOST=10.151.154.36
MEPSERVER_PORT=30188
CACRT_PATH=/tmp/mepserver/ca.crt

grep "${KONG_HOST}" /etc/hosts > /dev/null
if [ $? -ne 0 ]; then
    echo '127.0.0.1 edgegallery.org' >> /etc/hosts
fi


# create kong service for mepserver
curl --cacert "${CACRT_PATH}" --location --request POST "https://${KONG_HOST}:${KONG_ADMIN_PORT}/services" \
--header 'Content-Type: application/json' \
--data-raw '{
        "url": "https://'"${MEPSERVER_HOST}:${MEPSERVER_PORT}"'",
            "name": "https-mp1"
}'

# create kong route for mepserver
curl --cacert "${CACRT_PATH}" --location --request POST "https://${KONG_HOST}:${KONG_ADMIN_PORT}/services/https-mp1/routes" \
--header 'Content-Type: application/json' \
--data-raw '{
        "paths": ["/mepssl"],
            "name": "mepssl"
}'

# enable jwt for mepserver service
curl --cacert "${CACRT_PATH}" --location --request POST "https://${KONG_HOST}:${KONG_ADMIN_PORT}/services/https-mp1/plugins" \
--header 'Content-Type: application/json' \
--data-raw '{
        "name": "jwt"
}'

# enable appid-header plugin for mepserver service
curl --cacert "${CACRT_PATH}" --location --request POST "https://${KONG_HOST}:${KONG_ADMIN_PORT}/services/https-mp1/plugins" \
--header 'Content-Type: application/json' \
--data-raw '{
        "name": "appid-header"
}'
