#!/bin/bash

set -x

# initial variable
source ./scripts/mep_vars.sh

# deploy mepauth docker
docker run -itd --name mepauth -p 10443:10443 \
             --network mep-net \
             --link postgres-db:postgres-db \
             --link kong-service:kong-service \
             -v ${MEP_CERTS_DIR}/jwt_publickey:${MEPAUTH_SSL_DIR}/jwt_publickey \
             -v ${MEP_CERTS_DIR}/jwt_encrypted_privatekey:${MEPAUTH_SSL_DIR}/jwt_encrypted_privatekey \
             -v ${MEP_CERTS_DIR}/mepserver_tls.crt:${MEPAUTH_SSL_DIR}/server.crt \
             -v ${MEP_CERTS_DIR}/mepserver_tls.key:${MEPAUTH_SSL_DIR}/server.key \
             -v ${MEP_CERTS_DIR}/ca.crt:${MEPAUTH_SSL_DIR}/ca.crt \
             -v ${MEP_CERTS_DIR}/aes_key_file:${MEPAUTH_SSL_DIR}/aes_key_file \
             -e "MEPAUTH_DB_NAME=mepauth" \
             -e "MEPAUTH_DB_HOST=postgres-db" \
             -e "MEPAUTH_DB_PORT=5432" \
             -e "MEPAUTH_APIGW_HOST=kong-service" \
             -e "MEPAUTH_APIGW_PORT=8444"  \
             -e "MEPAUTH_CERT_DOMAIN_NAME=${DOMAIN_NAME}" \
             edgegallery/mepauth:latest $*
