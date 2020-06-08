#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
MepSslDir=/usr/mep/ssl
DOMAIN_NAME=edgegallery.org

# deploy mepauth docker
docker run -itd --name mepauth -p 10443:10443 \
             --network mep-net \
             --link postgres-db:postgres-db \
             --link kong-service:kong-service \
             -v ${CertDir}/jwt_publickey:${MepSslDir}/jwt_publickey \
             -v ${CertDir}/jwt_encrypted_privatekey:${MepSslDir}/jwt_encrypted_privatekey \
             -v ${CertDir}/mepserver_tls.crt:${MepSslDir}/server.crt \
             -v ${CertDir}/mepserver_tls.key:${MepSslDir}/server.key \
             -v ${CertDir}/ca.crt:${MepSslDir}/ca.crt \
             -v ${CertDir}/aes_key_file:${MepSslDir}/aes_key_file \
             -e "MEPAUTH_DB_NAME=mepauth" \
             -e "MEPAUTH_DB_HOST=postgres-db" \
             -e "MEPAUTH_DB_PORT=5432" \
             -e "MEPAUTH_APIGW_HOST=kong-service" \
             -e "MEPAUTH_APIGW_PORT=8444"  \
             -e "MEPAUTH_DB_SSLMODE=verify-ca" \
             -e "MEPAUTH_CERT_DOMAIN_NAME=${DOMAIN_NAME}" \
             edgegallery/mepauth:latest $*
