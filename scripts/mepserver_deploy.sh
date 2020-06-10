#!/bin/bash

# initial variable
set +x
source scripts/mep_vars.sh
set -x

# run mepserver docker
docker run -itd --name mepserver --network mep-net -e "SSL_ROOT=${MEPSERVER_SSL_DIR}" \
                                 -v ${MEP_CERTS_DIR}/mepserver_tls.crt:${MEPSERVER_SSL_DIR}/server.cer \
                                 -v ${MEP_CERTS_DIR}/mepserver_encryptedtls.key:${MEPSERVER_SSL_DIR}/server_key.pem \
                                 -v ${MEP_CERTS_DIR}/ca.crt:${MEPSERVER_SSL_DIR}/trust.cer \
                                 -v ${MEP_CERTS_DIR}/mepserver_cert_pwd:${MEPSERVER_SSL_DIR}/cert_pwd \
                                 edgegallery/mep:latest

