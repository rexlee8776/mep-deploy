#!/bin/bash

CertName=${CertName:-mepserver}
PassWd=te9Fmv%qaq
CertDir=/tmp/${CertName}
mkdir ${CertDir}
cd ${CertDir}

# generate ca certificate
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj /C=CN/ST=Beijing/L=Beijing/O=edgegallery/CN=edgegallery.org -out ca.csr
openssl x509 -req -days 365 -in ca.csr -extensions v3_ca -signkey ca.key -out ca.crt

# generate tls certificate
openssl genrsa -out ${CertName}_tls.key 2048
openssl rsa -in ${CertName}_tls.key -aes256 -passout pass:${PassWd} -out ${CertName}_encryptedtls.key

echo -n ${PassWd} > ${CertName}_cert_pwd

openssl req -new -key ${CertName}_tls.key -subj /C=CN/ST=Beijing/L=Beijing/O=edgegallery/CN=edgegallery.org -out ${CertName}_tls.csr
openssl x509 -req -in ${CertName}_tls.csr -extensions v3_usr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${CertName}_tls.crt
