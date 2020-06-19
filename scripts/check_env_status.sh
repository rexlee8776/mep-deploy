#!/bin/bash

docker ps -a | grep -E 'mepauth|mepserver|postgres-db|kong-service|mepagent'
