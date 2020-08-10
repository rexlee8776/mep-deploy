#!/bin/bash

set +o history
# initial variable
set +x
source scripts/mep_vars.sh
set -x

# run mepserver docker
## need to start bin/start.sh after mepserver docker run up
docker run -itd --name mepserver --network mep-net -e "SSL_ROOT=${MEPSERVER_SSL_DIR}" \
                                 --cap-drop All \
                                 -v ${MEP_CERTS_DIR}/mepserver_tls.crt:${MEPSERVER_SSL_DIR}/server.cer:ro \
                                 -v ${MEP_CERTS_DIR}/mepserver_encryptedtls.key:${MEPSERVER_SSL_DIR}/server_key.pem:ro \
                                 -v ${MEP_CERTS_DIR}/ca.crt:${MEPSERVER_SSL_DIR}/trust.cer:ro \
                                 "$REGISTRY_URL"edgegallery/mep:latest sh

set -o history
