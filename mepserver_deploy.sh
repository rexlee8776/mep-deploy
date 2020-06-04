#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}

# clean docker and certs
docker rm -f mepserver

# run mepserver docker
docker run -itd --name mepserver -p 127.0.0.1:30188:8088 -e "SSL_ROOT=/etc/mepssl" -e "MEP_SSL_MODE=1" \
                                 -v ${CertDir}/mepserver_tls.crt:/etc/mepssl/server.cer \
                                 -v ${CertDir}/mepserver_encryptedtls.key:/etc/mepssl/server_key.pem \
                                 -v ${CertDir}/ca.crt:/etc/mepssl/trust.cer \
                                 -v ${CertDir}/mepserver_cert_pwd:/etc/mepssl/cert_pwd \
                                 edgegallery/mep:latest
# check mepserver state
sleep 1
docker ps -a | grep mepserver
