#!/bin/bash

set -x

# add eguser and eggroup
groupadd -r -g 166 eggroup

useradd -r -g 166 -u 166 eguser

# add eguser to docker group
usermod -aG docker eguser

# create postgres work dir
mkdir -p /data/thirdpatry/postgres

chown eguser:eggroup /data/thirdparty/postgres

chmod 700 /data/thirdparty/postgres

# create kong work dir
mkdir -p /data/thirdparty/kong

chown eguser:eggroup /data/thirdparty/kong

chmod 700 /data/thirdparty/kong

# create cert generation dir
mkdir -p /home/EG-LDVS/mepserver

chown eguser:eggroup /home/EG-LDVS/mepserver

chmod 700 /home/EG-LDVS/mepserver

# create mep network
docker network create mep-net
