#!/usr/bin/env bash
set -euo pipefail
CONSUL_VERSION="1.6.2"

sudo apt update
sudo apt install -qy \
  curl \
  unzip

tmp_dir=$(mktemp -d)
consul_zip="$tmp_dir/consul.zip"

arch=""

if [[ "$(uname -m)" == "x86_64" ]]; then
  arch="amd64"
fi

curl -sL -o "$consul_zip" https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${arch}.zip

unzip -d "$tmp_dir" "$consul_zip"
sudo cp "$tmp_dir/consul" /usr/local/bin/consul
sudo chmod +x /usr/local/bin/consul

sudo mkdir -p /opt/consul

sudo consul agent \
  -data-dir /opt/consul \
  -bootstrap-expect 3 \
  -server \
  -retry-join 10.24.90.21 \
  -retry-join 10.24.90.22 \
  -retry-join 10.24.90.23
