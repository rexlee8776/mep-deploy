#!/bin/bash

set -x

groupadd -r -g 166 eggroup

useradd -r -g 166 -u 166 eguser

usermod -aG docker eguser

mkdir -p /data/mep

chown eguser:eggroup /data/mep

chmod 700 /data/mep

mkdir -p /tmp/mepserver

chown eguser:eggroup /tmp/mepserver

chmod 700 /tmp/mepserver
