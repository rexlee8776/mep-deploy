#!/bin/bash

# initial variables
set +x
source scripts/mep_vars.sh

cd ${MEP_CERTS_DIR}

# generate ca certificate
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj /C=CN/ST=Peking/L=Beijing/O=edgegallery/CN=${DOMAIN_NAME} -out ca.csr
openssl x509 -req -days 365 -in ca.csr -extensions v3_ca -signkey ca.key -out ca.crt

# generate tls certificate
openssl genrsa -out ${CERT_NAME}_tls.key 2048
openssl rsa -in ${CERT_NAME}_tls.key -aes256 -passout pass:${AES_KEY_PW} -out ${CERT_NAME}_encryptedtls.key

echo -n ${AES_KEY_PW} > ${CERT_NAME}_cert_pwd

openssl req -new -key ${CERT_NAME}_tls.key -subj /C=CN/ST=Beijing/L=Beijing/O=edgegallery/CN=${DOMAIN_NAME} -out ${CERT_NAME}_tls.csr
openssl x509 -req -in ${CERT_NAME}_tls.csr -extensions v3_usr -CA ca.crt -CAkey ca.key -CAcreateserial -out ${CERT_NAME}_tls.crt

# generate jwt public private key
openssl genrsa -out jwt_privatekey 2048
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey
openssl rsa -in jwt_privatekey -aes256 -passout pass:${AES_KEY_PW} -out jwt_encrypted_privatekey

# generate aes key file
echo -n ${AES_KEY_CONTENT} > aes_key_file

# remove unnecessary key file
rm ca.key
rm jwt_privatekey

# setup read permission
chown eguser:eggroup ${MEP_CERTS_DIR}/*
chmod 600 ${MEP_CERTS_DIR}/*
