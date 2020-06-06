#!/bin/bash

# initial variable
export CertName=mepserver
CertDir=/tmp/${CertName}
MepSslDir=/usr/mep/ssl

# clean docker and certs
docker rm -f mepserver

# run mepserver docker
docker run -itd --name mepserver -p 30188:8088 -e "SSL_ROOT=${MepSslDir}" -e "MEP_SSL_MODE=1" \
                                 -v ${CertDir}/mepserver_tls.crt:${MepSslDir}/server.cer \
                                 -v ${CertDir}/mepserver_encryptedtls.key:${MepSslDir}/server_key.pem \
                                 -v ${CertDir}/ca.crt:${MepSslDir}/trust.cer \
                                 -v ${CertDir}/mepserver_cert_pwd:${MepSslDir}/cert_pwd \
                                 edgegallery/mep:latest

