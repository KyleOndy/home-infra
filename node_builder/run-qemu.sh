#!/usr/bin/env bash
set -eu

function cleanup()
{
  docker kill "$NGINX_CONTAINER_ID"
}

trap cleanup EXIT

# to quit
# <ctrl> a + c + q

KERNEL=$1
INITRD=$2

NGINX_CONTAINER_ID=$(docker run --rm -d -p 80 -v "$(pwd)/../dist:/usr/share/nginx/html" nginx:stable)
PORT="$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "80/tcp") 0).HostPort }}' "$NGINX_CONTAINER_ID")"

set -x
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
