#!/bin/bash

set +o history
# initial variable
set +x
source scripts/mep_vars.sh
set -x

# run mepserver docker
docker run -itd --name mepserver --network mep-net -e "SSL_ROOT=${MEPSERVER_SSL_DIR}" \
                                 -v ${MEP_CERTS_DIR}/mepserver_tls.crt:${MEPSERVER_SSL_DIR}/server.cer:ro \
                                 -v ${MEP_CERTS_DIR}/mepserver_encryptedtls.key:${MEPSERVER_SSL_DIR}/server_key.pem:ro \
                                 -v ${MEP_CERTS_DIR}/ca.crt:${MEPSERVER_SSL_DIR}/trust.cer:ro \
                                 -v ${MEP_CERTS_DIR}/mepserver_cert_pwd:${MEPSERVER_SSL_DIR}/cert_pwd:ro \
                                 edgegallery/mep:latest

set -o history
