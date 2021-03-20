#!/usr/bin/env bash
set -Eeu
set -x

# https://github.com/jtopjian/scripts/blob/master/gluster/gluster-status.sh

###########################################################################
#
# GLUSTER INIT. The scrip that keeps getting scarier
#
# Here are the possible states the gluster service can be in when this script
# runs. After handling the case, we are able to exit the script.
# 1) Volume is shared and healthy, no maintenance needs to be done. This
#    happens when a script timer runs this, and is the normal operating mode.
# 2)
#
#
#
# 2) No valid share (all machines rebooted at the same time), peer and create
# 3) One or two nodes are disconnected (they were rebooted)
#
###########################################################################
#
# Exit Codes
# 0   All is well
# 1   Consul is not ready
# 2   Failed to get consul session ID (recoverable)
###########################################################################


VOLUME="shared"
BRICK="/scratch/gluster"
MOUNT="/mnt/shared"

get_peer_status() {
  # parse `gluster peer status` and return an easier to use format

  for peer in $(gluster peer status | grep '^Hostname: ' | awk '{print $2}'); do
    state=$(gluster peer status | grep -A 2 "^Hostname: $peer$" | grep '^State: ')
    if [[ "$state" == "State: Peer in Cluster (Connected)" ]]; then
      echo "$peer,in_cluster"
    elif [[ "$state" == "State: Peer Rejected (Connected)" ]]; then
      echo "$peer,rejected"
    else
      echo "$peer,unknown"
    fi
  done
}

peer_count() {
  gluster peer status | grep "^Number of Peers: " | cut -d' ' -f4
}

main() {
  echo "----------------------------------"
  echo "------- Script Start -------------"
  echo "----------------------------------"

  # `gluster peer status` can give us the following situations when run from
  # node W1. This matrix holds true for the other nodes too. C and D are just
  # mirrors of each other. E become C/D by fixing either node. This means I
  # only need to handle A, B, and C.
  #
  #  +---+-----------------------------+-----------------------------+
  #  |   | W2                          | W3                          |
  #  +---+-----------------------------+-----------------------------+
  #  | A | Peer in Cluster (Connected) | Peer in Cluster (Connected) |
  #  +---+-----------------------------+-----------------------------+
  #  | B |        -------------        |        -------------        |
  #  +---+-----------------------------+-----------------------------+
  #  | C | Peer in Cluster (Connected) | Peer Rejected (Connected)   |
  #  +---+-----------------------------+-----------------------------+
  #  | D | Peer Rejected (Connected)   | Peer in Cluster (Connected) |
  #  +---+-----------------------------+-----------------------------+
  #  | E | Peer Rejected (Connected)   | Peer Rejected (Connected)   |
  #  +---+-----------------------------+-----------------------------+

  # building heavily ontop of consul
  #
  # We can only fix another node if this node is good. Which ever node happens to run this script first, make a replica set with count 1, and add peers as needed?




  # todo: get rid of echos, or write to stderr?


  # if consul is not ready, don't even try to do anything
  #
  # Consul returns two double quotes `""` to represent no leader, which we use
  # as a proxy if this node's consul is healty or not
  #
  # We can not inline this curl call to localhost, becuase if it fails, consul
  # isn't listening, the exit code gets sawolled by the if statement and the
  # script keeps on trucking.
  leader="$(curl --fail -sS http://localhost:8500/v1/status/leader)"
  if [ '""' == "$leader" ]; then
    echo "Consul not ready"
    exit 1
  fi

  # return quick on the happiest path. This should be the path taken during
  # normal operation. If we are mounted, no need to even check everything else
  # below.
  if findmnt --mountpoint $MOUNT; then
    # todo: check gluster has replicated / healed before exiting with 0. The
    #       assumption here is once we exit with a zero, systemd will mount
    #       `/mnt/data` for us.
    echo "$(date): $(hostname -f): healthy" >> "$MOUNT/.heartbeat"
    exit 0
  fi

  # At this point there is some amount of bootstrapping to be done. To keep
  # complexity lower, we will do most of the setup on a leader node.

  # todo: is there a standard convention for where to put this, or naming?
  session_id_location=/run/glusterfs.session
  #session_id=
  if [[ -f $session_id_location ]]; then
    session_id=$(cat $session_id_location)
  else
    session_id=$(curl --fail -Ss -X PUT -d '{"Name": "glusterfs"}' http://localhost:8500/v1/session/create | jq -r '.ID')
    echo "$session_id" > $session_id_location
  fi

  if [[ -z $session_id ]]; then
    # this normally shoudln't happen.
    rm $session_id_location
    # todo: it would be nice to not bail here
    exit 2
  fi

  is_leader=$(curl --fail -Ss -X PUT -d "{\"name\": \"$(hostname -f)\"}" "http://localhost:8500/v1/kv/lead?acquire=${session_id}")


  if $is_leader; then
    echo "I am the leader! ALL MUST FOLLOW!"
  else
    echo "Guess I'll just be a follower"
  fi

  pc=$(peer_count)
  if [[ $pc -eq 0 ]]; then
    # We are the leader, and no peers, starting to the bottom
    echo "no peers!"
    #get_peer_status

    # no idea what I'm doing
    # optomistaiclly attempt to peer with all nodes? Should I exclude this host?
    gluster peer probe w1.dmz.509ely.com
    gluster peer probe w2.dmz.509ely.com
    gluster peer probe w3.dmz.509ely.com

    # lets just try some things...
  elif [[ $pc -eq 1 ]]; then
    echo "1 peer"
  elif [[ $pc -eq 2 ]]; then
    echo "2 peers"
  else
    echo "too many peers!"
  fi

  # to cretae a volume, I need two bricks, this one, and at least one peer.
  if [[ $(peer_count) -ge 1 ]] && [[ -z "$(gluster volume info)" ]]; then
    echo "creating volume"
    ps=$(get_peer_status)
    echo "Peer status:"
    echo "$ps"

    node=$(echo "$ps" | grep in_cluster | shuf -n1 | cut -d',' -f1)
    gluster volume create \
      "$VOLUME" \
      replica 2 \
      "$(hostname -f):$BRICK" \
             "${node}:$BRICK" \
      force
    gluster volume start "$VOLUME"
  fi


  # todo: assuming the volume is stated
  if gluster volume info $VOLUME | grep -q "$(hostname -f)"; then
    mkdir -p /mnt/shared # todo: do I need to create this?
    #mount -t glusterfs "$(hostname -f):/shared" /mnt/shared
    systemctl enable mnt-shared.mount
    systemctl start mnt-shared.mount
    exit 0 # todo
  fi

  exit 3
}

main
