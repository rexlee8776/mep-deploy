#!/bin/bash

docker run -itd --name mepauth -p 30080:8080 -p 10443:10443\
             --network mep-net \
             --link postgres-db:postgres-db \
             --link kong-service:kong-service \
             -v /tmp/publickey:/usr/mepauth/publickey \
             -v /tmp/privatekey:/usr/mepauth/privatekey \
             -e "MEPAUTH_DB_NAME=kong" \
             -e "MEPAUTH_DB_USER=kong" \
             -e "MEPAUTH_DB_PASSWD=kong" \
             -e "MEPAUTH_DB_HOST=postgres-db" \
             -e "MEPAUTH_DB_PORT=5432" \
             -e "MEPAUTH_APIGW_HOST=kong-service" \
             -e "MEPAUTH_APIGW_PORT=8001" \
             edgegallery/mepauth:latest

