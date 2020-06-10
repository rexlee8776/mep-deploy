#!/bin/bash

set -x

# add eguser and eggroup
groupadd -r -g 166 eggroup

useradd -r -g 166 -u 166 eguser

# add eguser to docker group
usermod -aG docker eguser

# create postgres work dir
POSTGRES_DATA=/data/thirdparty/postgres
KONG_DATA=/data/thirdparty/kong
MEP_CERTS_DIR=/home/EG-LDVS/mepserver

mkdir -p ${POSTGRES_DATA}

chown eguser:eggroup ${POSTGRES_DATA}

chmod 700 ${POSTGRES_DATA}

# create kong work dir
mkdir -p ${KONG_DATA}

chown eguser:eggroup ${KONG_DATA}

chmod 700 ${KONG_DATA}

# create cert generation dir
mkdir -p ${MEP_CERTS_DIR}

chown eguser:eggroup ${MEP_CERTS_DIR}

chmod 700 ${MEP_CERTS_DIR}

# create mep network
docker network create mep-net
