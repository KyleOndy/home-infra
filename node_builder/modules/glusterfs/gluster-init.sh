#!/usr/bin/env bash
set -Eeux

# https://github.com/jtopjian/scripts/blob/master/gluster/gluster-status.sh

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
SERVER_MOUNT="/gluster" # also known as a brick
CLIENT_MOUNT="/data"

# is everything good?
for peer in $(gluster peer status | grep '^Hostname: ' | awk '{print $2}'); do
  state=$(gluster peer status | grep -A 2 "^Hostname: $peer$" | grep '^State: ')
  if [[ "$state" == "State: Peer in Cluster (Connected)" ]]; then
    echo "$peer: all is good"
  elif [[ "$state" == "State: Peer Rejected (Connected)" ]]; then
    echo "$peer is broken. Removing from cluster"
      gluster volume remove-brick shared replica 2 "$peer:$SERVER_MOUNT" force
      gluster volume add-brick shared replica 3 "$peer:$SERVER_MOUNT" force
  else
    echo "Unknown state: $state"
  fi
done


## This means volume is mounted and all three nodes are health
#mkdir -p "$SERVER_MOUNT/.meta"
#echo "$(date): $(hostname): healthy" >> "$SERVER_MOUNT/.meta/health"
#exit 0
# Lets just exit.

# Is only one node down? Remove it, let it try and rejoin


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
