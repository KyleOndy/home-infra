#!/usr/bin/env bash
set -eou pipefail

# used to bootstrap fresh ubuntu images onto cluser nodes.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

is_installed() {
  if type "$1" >/dev/null 2>&1; then
    return 0
  else
    return
  fi
}

install_prereqs_if_needed() {
  PREREQS=(apt-cacher-ng curl jq unzip)
  need_to_install="false"
  for pkg in "${PREREQS[@]}"; do
    if is_installed "$pkg"; then
      need_to_install="true"
    fi
  done

  if [ $need_to_install == "true" ]; then
    sudo apt update -y
    sudo apt install -qy ${PREREQS[*]}
  fi

  if ! is_installed "docker"; then
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$(whoami)"
  fi

  if ! is_installed "docker-compose"; then
    sudo curl -L --fail https://github.com/docker/compose/releases/download/1.24.1/run.sh -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi
}

enable_pxe() {
  curl -sX PUT "http://${MY_IP}:9090/build/$1"
}

main() {
  pushd "$DIR"
  install_prereqs_if_needed

  # todo: this seems like this is pretty fragile
  MY_IP=$(hostname -I | awk '{print $1}')
  echo "My IP: $MY_IP"

  # todo: there is proably a better way to handle injects the IP address.
  sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/docker-compose.yml"
  sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/waitron/config.yaml"

  # stop anything that was running before to avoid old state
  docker-compose stop
  docker-compose up --build -d

  # make sure everyting is up
  echo "sleeping 5..."
  sleep 5

  # todo: add abilty to selectivly enable each of these.
  enable_pxe c01m01.dmz.509ely.com
  enable_pxe c01m02.dmz.509ely.com
  enable_pxe c01m03.dmz.509ely.com
  enable_pxe c01w01.dmz.509ely.com
  enable_pxe c01w02.dmz.509ely.com
  enable_pxe c01w02.dmz.509ely.com

  popd
}
