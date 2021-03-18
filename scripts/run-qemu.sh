#!/usr/bin/env bash
set -veuo pipefail

function cleanup()
{
  docker kill "$NGINX_CONTAINER_ID"
}

trap cleanup EXIT

# to quit
# <ctrl> a + c + q

KERNEL=$1
INITRD=$2

NGINX_CONTAINER_ID=$(docker create -p 80 nginx:stable)
docker cp "$3" "$NGINX_CONTAINER_ID:/usr/share/nginx/html"
docker start "$NGINX_CONTAINER_ID"
PORT="$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "80/tcp") 0).HostPort }}' "$NGINX_CONTAINER_ID")"

qemu-system-x86_64 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -nographic \
  -smp 2 \
  --enable-kvm \
  -cpu host \
  -append "
    console=ttyS0
    boot=ramdisk
    hostname=foobar
    ramroot=http://10.24.89.110:$PORT/ramroot.tar.xz" \
  -m 4G
set +x
