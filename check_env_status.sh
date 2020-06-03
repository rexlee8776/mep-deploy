#!/bin/bash

docker ps | grep -E 'mepauth|mepserver|postgres-db|kong-service'
