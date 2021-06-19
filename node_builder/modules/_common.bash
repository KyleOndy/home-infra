#!/usr/bin/env bash
set -Eeu

common.install_packages() {
  packages=$*
  apt-get -qq update
  # the Use-Pty option is fom https://askubuntu.com/a/668859
  echo "$packages" | xargs -- apt-get install -qq -o=Dpkg::Use-Pty=0
}
