#!/usr/bin/env bash

# used to bootstrap a new cluster. Need a single node up on the network, then run this script.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$DIR"

is_installed() {
  if type "$1" >/dev/null 2>&1; then
    return 0
  else
    return
  fi
}

install_prereqs() {
  echo "installing prereqs from apt"
  sudo apt update
  sudo apt install -qy \
    curl
}

if is_installed "curl"; then
  echo "curl installed!"
else
  install_prereqs
fi

if is_installed "docker"; then
  echo "docker installed"
else
  echo "installing docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $(whoami)
fi

if is_installed "docker-compose"; then
  echo "docker-compose is installed"
else
  echo "install docker-compose (via container)..."
  sudo curl -L --fail https://github.com/docker/compose/releases/download/1.24.1/run.sh -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

docker-compose up --build

popd
