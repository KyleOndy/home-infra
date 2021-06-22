#!/usr/bin/env bash
set -Eeu

# common functions to be reused in modules

# easitly install packages. usage:
# 
# common.install_packages foo bar
#
#
# packages=(
#   foo # bizz
#   bar # bazz
# )
# common.install_packages "${packages[@]}"
#
#
common.install_packages() {
  packages=$*
  apt-get -qq update
  # the Use-Pty option is fom https://askubuntu.com/a/668859
  echo "$packages" | xargs -- apt-get install -qq -o=Dpkg::Use-Pty=0
}
