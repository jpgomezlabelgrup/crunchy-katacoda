#!/bin/bash


set -e -u

echo 'adding postgres rpm'
yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

echo 'installing postgres and backrest'
yum install -y postgresql10 pgbackrest


docker network create --driver bridge pgnet

echo 'starting postgres docker container'
docker run \
    --publish 5432:5432 \
    --volume pgdata:/pgdata \
    --env PG_MODE=primary \
    --env PG_USER=testuser \
    --env PG_PASSWORD=password \
    --env PG_DATABASE=userdb \
    --env PG_PRIMARY_USER=primaryuser \
    --env PG_PRIMARY_PORT=5432 \
    --env PG_PRIMARY_PASSWORD=password \
    --env PG_ROOT_PASSWORD=password \
    --network=pgnet \
    --name=primary \
    --hostname=primary \
    --detach crunchydata/crunchy-postgres:centos7-11.2-2.3.1

echo 'starting pgadmin container'
docker run \
    --publish 5050:5050 \
    --volume pgadmin:/var/lib/pgadmin \
    --env=PGADMIN_SETUP_EMAIL='admin@crunchydata.com' \
    --env=PGADMIN_SETUP_PASSWORD='password' \
    --network=pgnet \
    --name=pgadmin \
    --hostname=pgadmin \
    --detach crunchydata/crunchy-pgadmin4:centos7-11.2-2.3.1
echo 'done'

