#!/usr/bin/env bash
set -eo pipefail
set -x

dc="/opt/home-infra/docker-compose.yml"
docker-compose -f "$dc" up --build -d --remove-orphans
