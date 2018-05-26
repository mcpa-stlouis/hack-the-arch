#!/bin/bash
# This script attempts to start a safe production deployment of HTA.

if [ -z `which docker` ]; then
  echo 'You must install docker for this to work... we recommend https://docs.docker.com/install/'
  exit -1
fi

if [ -z `which docker-compose` ]; then
  echo 'You must install docker-compose for this to work... we recommend https://docs.docker.com/compose/install/'
  exit -1
fi

DOCKER_EDITION=$(docker -v | awk '{ print $3 }' | cut -d'-' -f2 | tr ',' ' ' )
if [ "$DOCKER_EDITION" != "ce " ]; then
  echo 'WARNING: HTA has not been tested with this version of Docker...  continue at your own risk.'
  read WAIT_FOR_INPUT
fi

DOCKER_VERSION=$(docker -v | awk '{ print $3 }' | cut -d'-' -f1 )
DOCKER_MAJOR_VER=$(echo $DOCKER_VERSION | cut -d'.' -f1)
DOCKER_MINOR_VER=$(echo $DOCKER_VERSION | cut -d'.' -f2)
if [ $DOCKER_MAJOR_VER -ge '18' ] && [ $DOCKER_MINOR_VER -lt '03' ]; then
  echo 'Detected docker version less than 18.03... aborting...  Update docker: https://docs.docker.com/install/'
  exit -1
fi

DOCKER_COMPOSE_VERSION=$(docker-compose -v | awk '{ print $3 }' | cut -d',' -f1)
DOCKER_COMPOSE_MAJOR_VER=$(echo $DOCKER_COMPOSE_VERSION | cut -d'.' -f1)
DOCKER_COMPOSE_MINOR_VER=$(echo $DOCKER_COMPOSE_VERSION | cut -d'.' -f2)
if [ $DOCKER_COMPOSE_MAJOR_VER -ge '1' ] && [ $DOCKER_COMPOSE_MINOR_VER -lt '21' ]; then
  echo 'Detected docker-compose version less than 1.21... aborting...  Update compose: https://docs.docker.com/compose/install/'
  exit -1
fi

if [ $(stat -f %m ./certs/server.key) -eq 1476129400 ]; then
  echo 'You MUST generate your own certificates to deploy HTA. See instructions in ./certs/README.md'
  exit -1
fi

if [ ! -f ./.env ]; then
  echo 'You MUST copy ./.env_sample to ./.env and set the necessary variables there for HTA to work properly'
  exit -1
fi

SECRET_KEY_BASE=$(grep SECRET_KEY_BASE .env | cut -d'=' -f2)
if [ $SECRET_KEY_BASE = 'CHANGE_ME' ]; then
  echo 'Change your secret key base in .env (it can be any large random string)!'
  exit -1
fi

HOST=$(grep HOST .env | cut -d'=' -f2)
if [ $SECRET_KEY_BASE = 'CHANGE_ME' ]; then
  echo 'Change your host in .env!'
  exit -1
fi

if [ $(docker-compose ps | wc -l) -gt 2 ]; then
  echo 'Detected existing instance of HTA running... kill it, then restart...'
  docker-compose down -v
fi

docker-compose up -d
docker-compose run web rails db:migrate
docker-compose run web rails db:seed
docker-compose run web rails assets:precompile

echo 'All done!  HTA should now be browsable on your local IP!'
