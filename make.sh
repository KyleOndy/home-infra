#!/usr/bin/env bash
set -veuo pipefail

# Build the Docker image
docker build -f Dockerfile.kernel -t ramroot-kernel .
# Extract the kernel and initrd
docker run --rm -v "$PWD:/host" ramroot-kernel bash -c 'cp -v /boot/initrd.img-* /boot/vmlinuz-* /host'

sudo chown "$(whoami)" vmlinuz-*

## Build the Docker image
#docker build -f Dockerfile.ramroot -t ramroot .
## Convert the Docker image to a ramroot
#tools/docker-to-ramroot ramroot ramroot.tar.xz
