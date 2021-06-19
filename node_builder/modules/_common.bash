#!/usr/bin/env bash
set -Eeu

common.install_packages() {
  packages=$*
  apt-get update -qq
  apt-get install -yq "$packages"
}
