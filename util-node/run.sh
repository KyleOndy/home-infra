#!/usr/bin/env bash
set -eo pipefail
set -x

dc="/opt/home-infra/docker-compose.yml"

if [[ "$1" == '-force' ]]; then
          docker-compose -f "$dc" down
fi

#sudo chown -R "$(whoami)" /opt/home-infra/files/
#sudo chmod -R 755 /opt/home-infra/files

docker-compose -f "$dc" pull
docker-compose -f "$dc" up --build -d --remove-orphans
docker-compose -f "$dc" logs -f --tail 40
