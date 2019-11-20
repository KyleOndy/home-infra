#!/usr/bin/env bash
set -eou pipefail

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

if is_installed "apt-cacher-ng"; then
  echo "apt-cacher-ng is installed"
else
  install_prereqs
fi

if is_installed "unzip"; then
  echo "unzip is installed"
else
  install_prereqs
fi

if is_installed "nomad"; then
  echo "nomad is on PATH"
else
  download_and_install_nomad
fi

if is_installed "jq"; then
  echo "jq is installed"
else
  install_prereqs
fi

# todo: this is pretty fragile
MY_IP=$(hostname -I | awk '{print $1}')
echo "My IP: $MY_IP"

sed -ie "s|d-i mirror/http/proxy string .*|d-i mirror/http/proxy string http://${MY_IP}:3142/|" "$DIR/images/preseed.cfg"

sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/docker-compose.yml"
sed -ie "s/{{MY_IP}}/${MY_IP}/" "$DIR/waitron/config.yaml"

docker-compose stop
docker-compose up --build -d
echo "sleeping 5..."
sleep 5

TOKEN=$(curl -s -X PUT http://${MY_IP}:9090/build/master01 | jq -r '.Token')
curl -s -X GET "http://${MY_IP}:9090/status" | jq '.'
#curl -s -X GET "http://${MY_IP}:9090/cancel/master01/${TOKEN}"

curl -sX GET http://${MY_IP}:9090/template/preseed/master01/${TOKEN} > /tmp/preseed.txt

#docker-compose logs --follow

popd

