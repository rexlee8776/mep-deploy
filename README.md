# MEP deployment using docker

```
.
├── check_env_status.sh # check docker status
├── clean_all.sh # clean certificates and docker
├── generate_cert.sh # generate certificates and keys
├── mepauth_deploy.sh # deploy mepauth docker
├── mepserver_deploy.sh # deploy mepserver docker
├── pgsql_kong_deploy.sh # deploy pgsql and kong docker
├── mep_pre_deploy.sh # add eguser and eggroup
└── mep_one_key_deploy.sh # mep one key deploy

```

# How to deploy Mep
Step 1: ./mep_pre_deploy.sh
It would create eguser and eggroup in your env and set up directory permissions.

Step 2: ./mep_one_key_deploy.sh
It would run pgsql, kong, mepauth and mepserver docker
