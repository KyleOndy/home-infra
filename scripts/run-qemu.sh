#!/usr/bin/env bash
set -Eeu

function cleanup()
{
  docker kill "$NGINX_CONTAINER_ID"
}

trap cleanup EXIT

# to quit
# <ctrl> a + c + q

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <kernel> <initrd> <ramroot>"
  exit 1
fi

KERNEL=$1
INITRD=$2
RAMROOT=$3

NGINX_CONTAINER_ID=$(docker run --rm -d -p 80 -v "$PWD/$(dirname "$RAMROOT"):/usr/share/nginx/html" nginx:stable)
PORT="$(docker inspect -f '{{ (index (index .NetworkSettings.Ports "80/tcp") 0).HostPort }}' "$NGINX_CONTAINER_ID")"

rm -f nomados.qcow2
qemu-img create -f qcow2 nomados.qcow2 32G
qemu-system-x86_64 \
  -kernel "$KERNEL" \
  -initrd "$INITRD" \
  -nographic \
  -smp 2 \
  --enable-kvm \
  -net user,hostfwd=tcp::10022-:22 \
  -net nic \
  -netdev user,id=n0,dns=10.24.89.4,ifnamw=enp2s0 \
  -drive file=nomados.qcow2,media=disk,if=none,id=NVME1 \
  -device nvme,drive=NVME1,serial=nvme-1 \
  -cpu host \
  -append "
    console=ttyS0
    boot=ramdisk
    hostname=foobar
    ramroot=http://10.24.89.110:$PORT/$(basename "$RAMROOT")" \
  -m 4G
