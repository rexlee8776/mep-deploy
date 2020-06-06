#!/bin/bash

set -x

# add eguser and eggroup
groupadd -r -g 166 eggroup

useradd -r -g 166 -u 166 eguser

# add eguser to docker group
usermod -aG docker eguser

# create postgres work dir
mkdir -p /data/mep/postgres

chown eguser:eggroup /data/mep/postgres

chmod 700 /data/mep/postgres

# create kong work dir
mkdir -p /data/mep/kong

chown eguser:eggroup /data/mep/kong

chmod 700 /data/mep/kong

# create cert generation dir
mkdir -p /tmp/mepserver

chown eguser:eggroup /tmp/mepserver

chmod 700 /tmp/mepserver