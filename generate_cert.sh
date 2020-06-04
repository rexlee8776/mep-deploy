#!/bin/bash

CertName=${CertName:-mepserver}
PassWd=te9Fmv%qaq
AesKey=te9Fmv%qaqte9Fmv%qaqte9Fmv%qaqte9Fmv%qaqte9Fmv%qaqte9Fmv%qaq
CertDir=/tmp/${CertName}

cd ${CertDir}

# generate ca certificate
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj /C=CN/ST=Peking/L=Beijing/O=edgegallery/CN=edgegallery.org -out ca.csr
openssl x509 -req -days 365 -in ca.csr -extensions v3_ca -signkey ca.key -out ca.crt

# generate tls certificate
openssl genrsa -out ${CertName}_tls.key 2048
openssl rsa -in ${CertName}_tls.key -aes256 -passout pass:${PassWd} -out ${CertName}_encryptedtls.key

echo -n ${PassWd} > ${CertName}_cert_pwd

openssl req -new -key ${CertName}_tls.key -subj /C=CN/ST=Beijing/L=Beijing/O=edgegallery/CN=edgegallery.org -out ${CertName}_tls.csr
openssl x509 -req -in ${CertName}_tls.csr -extensions v3_usr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${CertName}_tls.crt

# generate jwt public private key
openssl genrsa -out jwt_privatekey 2048
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey
openssl rsa -in jwt_privatekey -aes256 -passout pass:${PassWd} -out jwt_encrypted_privatekey

# generate aes key file
echo -n ${AesKey} > aes_key_file

# setup read permission
chown eguser:eggroup ${CertDir}/*
chmod 600 ${CertDir}/*