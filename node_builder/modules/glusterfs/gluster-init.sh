#!/usr/bin/env bash
set -eu
set -x

VOLUME_NAME="shared"
SERVER_MOUNT="/gluster"
CLIENT_MOUNT="/data"

# todo: script for startup
gluster peer probe w1
gluster peer probe w2
gluster peer probe w3

# happy path, volume exisits, just join it.
if ! gluster volume list | grep -xq "$VOLUME_NAME"; then
  gluster volume create \
    "$VOLUME_NAME" \
    replica 3 \
    w1.dmz.509ely.com:"$SERVER_MOUNT" \
    w2.dmz.509ely.com:"$SERVER_MOUNT" \
    w3.dmz.509ely.com:"$SERVER_MOUNT" \
    force

    #if [[ "$ec" -eq 2 ]]; then
    #  # handles: volume create: <volume> failed: <mount> is already part of a volume
    #  systemctl stop glusterd

    #  setfattr -xf trusted.glusterfs.volume-id "$SERVER_MOUNT"
    #  setfattr -xf trusted.gfid "$SERVER_MOUNT"
    #  rm -rf "$SERVER_MOUNT/.glusterfs"

    #  systemctl start glusterd
    #fi
fi

gluster volume start "$VOLUME_NAME" force
# todo: volume set "$VOLUME_NAME" auth.allow w1,w2,w3

mkdir -p "$CLIENT_MOUNT"
mount -t glusterfs localhost:"$VOLUME_NAME" "$CLIENT_MOUNT"
