#!/bin/bash

# update mep docker images
docker rm -f mepauth mepserver kong-service postgres-db mep-agent

docker rmi edgegallery/mep:latest
docker rmi edgegallery/mepauth:latest
docker rmi edgegallery/mep-agent:latest


docker pull edgegallery/mep:latest
docker pull edgegallery/mepauth:latest
docker pull edgegallery/mep-agent:latest
