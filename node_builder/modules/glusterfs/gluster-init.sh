#!/usr/bin/env bash
set -eu
set -x

###########################################################################
#
# GLUSTER INIT. The scrip that keeps getting scarier
#
# Here are the possible states the gluster service can be in when this script
# runs.
# 1) Volume is shared and health, shouldn't need to do anything
# 2) No valid share (all machines rebooted at the same time), peer and create
# 3) One or two nodes are disconnected (they were rebooted)
#
###########################################################################

VOLUME_NAME="shared"
SERVER_MOUNT="/gluster"
CLIENT_MOUNT="/data"

# is everything good? Lets just exit.

# are things in a broken state? Try and fix it
gluster peer status | grep 'State: Peer Rejected' -B2 | grep Hostname | cut -d" " -f2 | xargs -I{} bash -c 'yes | gluster peer detach {} force'
gluster peer status | grep 'State: Peer Rejected' -B2 | grep Uuid | cut -d" " -f2 | xargs -I{} rm /var/lib/glusterd/peers/{}

# todo: script for startup
gluster peer probe w1.dmz.509ely.com
gluster peer probe w2.dmz.509ely.com
gluster peer probe w3.dmz.509ely.com

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
