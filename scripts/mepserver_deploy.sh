#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
MepSslDir=/usr/mep/ssl

# run mepserver docker
docker run -itd --name mepserver --network mep-net -p 30188:8088 -e "SSL_ROOT=${MepSslDir}" \
                                 -v ${CertDir}/mepserver_tls.crt:${MepSslDir}/server.cer \
                                 -v ${CertDir}/mepserver_encryptedtls.key:${MepSslDir}/server_key.pem \
                                 -v ${CertDir}/ca.crt:${MepSslDir}/trust.cer \
                                 -v ${CertDir}/mepserver_cert_pwd:${MepSslDir}/cert_pwd \
                                 edgegallery/mep:latest

