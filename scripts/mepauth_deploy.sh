#!/bin/bash

set +o history
# initial variable
set +x
source scripts/mep_vars.sh
set -x

cp -r mepauth-conf /tmp/
chown -R eguser:eggroup /tmp/mepauth-conf/
chmod -R 640 /tmp/mepauth-conf/

# deploy mepauth docker
docker run -itd --name mepauth \
             --cap-drop All \
             --network mep-net \
             --link kong-service:kong-service \
             -v ${MEP_CERTS_DIR}/jwt_publickey:${MEPAUTH_KEYS_DIR}/jwt_publickey:ro \
             -v ${MEP_CERTS_DIR}/jwt_encrypted_privatekey:${MEPAUTH_KEYS_DIR}/jwt_encrypted_privatekey:ro \
             -v ${MEP_CERTS_DIR}/mepserver_tls.crt:${MEPAUTH_SSL_DIR}/server.crt:ro \
             -v ${MEP_CERTS_DIR}/mepserver_tls.key:${MEPAUTH_SSL_DIR}/server.key:ro \
             -v ${MEP_CERTS_DIR}/ca.crt:${MEPAUTH_SSL_DIR}/ca.crt:ro \
             -v ${MEPAUTH_CONF_PATH}:/usr/mep/mepauth.properties \
             -e "MEPAUTH_APIGW_HOST=kong-service" \
             -e "MEPAUTH_APIGW_PORT=8444"  \
             -e "MEPAUTH_CERT_DOMAIN_NAME=${DOMAIN_NAME}" \
             edgegallery/mepauth:latest

set -o history
