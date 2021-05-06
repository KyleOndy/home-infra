#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# todo: port to Makefile

src_chroot=$(mktemp -d)

pkgs=(
neovim
)
./bin/generate_chroot "$src_chroot" "${pkgs[@]}"

# even though the naive path would be to provison the chroot we just created,
# still copy it over incase we want to inspect the base chroot, or tweak
# something.

dist_chroot=$(mktemp -d)
./bin/copy_chroot "$src_chroot" "$dist_chroot"

# these modules are installed in the order given in the array.
modules=(
babashka
docker
keepalived
nomad_agent
traefik
consul_agent
glusterfs
mounts
scheduled_reboot
)

for module in "${modules[@]}"; do
  ./bin/provision_chroot "$dist_chroot" "${DIR}/modules/$module/install"
done
