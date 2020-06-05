#!/bin/bash
# clean docker and certs
docker rm -f mepauth
# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
MepauthConf=/usr/mepauth/conf

docker run -itd --name mepauth -p 127.0.0.1:10443:10443\
             --network mep-net \
             --link postgres-db:postgres-db \
             --link kong-service:kong-service \
             -v ${CertDir}/jwt_publickey:${MepauthConf}/jwt_publickey \
             -v ${CertDir}/jwt_encrypted_privatekey:${MepauthConf}/jwt_encrypted_privatekey \
             -v ${CertDir}/mepserver_tls.crt:${MepauthConf}/server.crt \
             -v ${CertDir}/mepserver_tls.key:${MepauthConf}/server.key \
             -v ${CertDir}/ca.crt:${MepauthConf}/ca.crt \
             -v ${CertDir}/aes_key_file:${MepauthConf}/aes_key_file \
             -e "MEPAUTH_DB_NAME=mepauth" \
             -e "MEPAUTH_DB_USER=mepauth" \
             -e "MEPAUTH_DB_PASSWD=mepauth" \
             -e "MEPAUTH_DB_HOST=postgres-db" \
             -e "MEPAUTH_DB_PORT=5432" \
             -e "MEPAUTH_APIGW_HOST=kong-service" \
             -e "MEPAUTH_APIGW_PORT=8444"  \
             -e "MEPAUTH_DB_SSLMODE=verify-ca" \
             edgegallery/mepauth:latest $*
