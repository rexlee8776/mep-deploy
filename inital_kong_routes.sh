#!/bin/bash

HOST=127.0.0.1
KONG_ADMIN_PORT=8444
MEPSERVER_PORT=30188

set -x

# create kong service for mepserver
curl --location --request POST 'https://127.0.0.1:8444/services' \
--header 'Content-Type: application/json' \
--data-raw '{
        "url": "https://127.0.0.1:30188",
            "name": "https-mp1"
}'

# create kong route for mepserver
curl --location --request POST 'https://127.0.0.1:8444/services/https-mp1/routes' \
--header 'Content-Type: application/json' \
--data-raw '{
        "paths": ["/mepssl"],
            "name": "mepssl"
}'

# enable jwt for mepserver service
curl --location --request POST 'https://127.0.0.1:8444/services/https-mp1/plugins' \
--header 'Content-Type: application/json' \
--data-raw '{
        "name": "jwt"
}'
