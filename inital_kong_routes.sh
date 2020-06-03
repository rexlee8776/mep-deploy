#!/bin/bash

HOST=159.138.61.91
KONG_ADMIN_PORT=8444
MEPSERVER_PORT=30188

set -x

# create kong service for mepserver
curl --location --request POST 'https://${HOST}:${KONG_ADMIN_PORT}/services' \
--header 'Content-Type: application/json' \
--data-raw '{
        "url": "https://${HOST}:${MEPSERVER_PORT}",
            "name": "https-mp1"
}'

# create kong route for mepserver
curl --location --request POST 'https://${HOST}:${KONG_ADMIN_PORT}/services/https-mp1/routes' \
--header 'Content-Type: application/json' \
--data-raw '{
        "paths": ["/mepssl"],
            "name": "mepssl"
}'

# enable jwt for mepserver service
curl --location --request POST 'https://${HOST}:${KONG_ADMIN_PORT}/services/https-mp1/plugins' \
--header 'Content-Type: application/json' \
--data-raw '{
        "name": "jwt"
}'
