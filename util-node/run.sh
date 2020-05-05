#!/usr/bin/env bash
set -eu

# build before trying to run the images
docker-compose build --pull
docker-compose up -d --remove-orphans
docker-compose logs -f --timestamps --tail 40
