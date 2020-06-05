# MEP deployment using docker

## dir tree info

```
# tree -A
.
├── clean_all.sh # clean certificates and docker
├── mep_one_key_deploy.sh # mep one key deploy all dockers
├── postman # mepserver and mepauth apis
│   ├── mepauth-v1.postman_collection.json
│   ├── mepserver-plugtest.postman_collection.json
│   └── mepserver-v1.postman_collection.json
├── README.md
└── scripts
    ├── check_env_status.sh
    ├── generate_cert.sh
    ├── inital_kong_routes.sh
    ├── mepauth_deploy.sh
    ├── mep_pre_deploy.sh
    ├── mepserver_deploy.sh
    └── pgsql_kong_deploy.sh

```

# How to deploy Mep

sudo ./mep_one_key_deploy.sh
It would first clean env and then start  pgsql, kong, mepauth and mepserver docker.
