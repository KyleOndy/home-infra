#!/usr/bin/env bash

# used to bootstrap a new cluster. Need a single node up on the network, then run this script.

is_installed() {
  if type "$1" >/dev/null 2>&1; then
    return 0
  else
    return
  fi
}

if is_installed "docker"; then
  echo "docker installed"
else
  echo "todo: install docker"
  exit 1
fi

if is_installed "docker-compose"; then
  echo "docker-compose is installed"
else
  echo "todo: no docker-compsoe on arm. use docker-compose container"
  exit 1
fi
