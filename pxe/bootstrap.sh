#!/usr/bin/env bash
set -eou pipefail

# used to bootstrap fresh ubuntu images onto cluser nodes.

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
  sudo apt update -y
  sudo apt install -qy \
    apt-cacher-ng \
    curl \
    jq \
    unzip
}

download_and_install_nomad() {
  version="0.10.1"
  arch="amd64" # default
  tmp=$(mktemp -d)
  zip_location="$tmp/nomad.zip"

  if uname -a | grep -q ARM; then
    echo "todo: ARM?"
    exit 1
  fi

  download_url="https://releases.hashicorp.com/nomad/${version}/nomad_${version}_linux_${arch}.zip"
  echo "url: $download_url"
  curl -sL -o "$zip_location" "$download_url"
  unzip -d "$tmp/nomad" "$zip_location"
  sudo cp -v "$tmp/nomad/nomad" /usr/local/bin/nomad
  sudo chmod +x /usr/local/bin/nomad
}

enable_pxe() {
  curl -sX PUT "http://${MY_IP}:9090/build/$1"
}

if ! is_installed "curl" || ! is_installed "apt-cacher-ng" || ! is_installed "jq" || ! is_installed "unzip"; then
  install_prereqs
fi

if ! is_installed "docker"; then
  echo "installing docker..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$(whoami)"
fi

if ! is_installed "docker-compose"; then
  echo "install docker-compose (via container)..."
  sudo curl -L --fail https://github.com/docker/compose/releases/download/1.24.1/run.sh -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# todo: this is pretty fragile
MY_IP=$(hostname -I | awk '{print $1}')
echo "My IP: $MY_IP"

# todo: there is proably a better way to handle injects the IP address.
sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/docker-compose.yml"
sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/waitron/config.yaml"

# stop anything that was running before
docker-compose stop
docker-compose up --build -d

# make sure everyting is up
echo "sleeping 5..."
sleep 5

# todo: add abilty to selectivly enable each of these.
enable_pxe master01.cluster01.509ely.com
enable_pxe master02.cluster01.509ely.com
enable_pxe master03.cluster01.509ely.com
enable_pxe worker01.cluster01.509ely.com
enable_pxe worker02.cluster01.509ely.com
enable_pxe worker02.cluster01.509ely.com

popd
