#!/usr/bin/env bash
set -Eeu

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
BRICK="/scratch/gluster/brick"
MOUNT="/mnt/shared"
CONSUL="http://127.0.0.1:8500"

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

is_consul_ready() {
  status=$(curl -sS --fail "$CONSUL/v1/health/node/$(hostname)" | jq --raw-output '. | .[] | select(.CheckID == "serfHealth") | .Status')
  if [[ "$status" == "passing" ]]; then
    return 0
  else
    return 1
  fi
}

is_leader() {
  # todo: is there a standard convention for where to put this, or naming?
  session_id_location=/run/glusterfs.session
  if [[ -f $session_id_location ]]; then
    session_id=$(cat $session_id_location)
  else
    session_id=$(curl --fail -Ss -X PUT -d '{"Name": "glusterfs"}' "$CONSUL/v1/session/create" | jq -r '.ID')
    echo "$session_id" > $session_id_location
  fi

  if [[ "true" == "$(curl --fail -Ss -X PUT -d "{\"name\": \"$(hostname -f)\"}" "http://localhost:8500/v1/kv/lead?acquire=${session_id}")" ]]; then
    return 0
  else
    return 1
  fi
}

main() {
  echo "------- Script Start -------------"

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

###########################################################################
# TRY 3
#
# (rough proccess)
#
#   Is $(hostname) brick in the volume && is brick replicated? (maybe?) -> mounnt /mnt/shared (systemd mount)
#   if ! leader -> return 0
#   Are there unhealty peers? -> remove, dropping replica size if needed
#   Peer with all (hard coded list)
#   does volume need to be created && do we hava at least one peer connected
#     -> crete replica 2 with a peer
#     -> start volume
#   are there connected peers not in volume? -> add peer, replicate size +1
#
###########################################################################



  is_consul_ready || exit 11

  #if is_leader; then set -x; fi # todo: remove

  if is_leader; then
    echo "I am the leader! ALL MUST FOLLOW!"
  else
    echo "Guess I'll just be a follower"
  fi

  # return quick on the happiest path. This should be the path taken during
  # normal operation. If we are mounted, no need to even check everything else
  # below.
  if findmnt --mountpoint $MOUNT > /dev/null; then
    # todo: check gluster has replicated / healed before exiting with 0. The
    #       assumption here is once we exit with a zero, systemd will mount
    #       `/mnt/data` for us.
    echo "$(date): $(hostname -f): healthy" >> "$MOUNT/.heartbeat"
  elif gluster volume info $VOLUME | grep -P "Brick\d: " | grep -q "$(hostname -f)"; then
      # I don't know if the hostname could ever be in a context besides the
      # bricks, so be a little defensive in the check above.
      mkdir -p /mnt/shared # todo: do I need to create this?
      systemctl enable mnt-shared.mount
      systemctl start mnt-shared.mount
  fi

  # the leader has more work to do
  if ! is_leader; then exit 0; fi


  #if is_leader; then set -x; fi # todo: remove
  # are any of our peers in a bad state?
  # todo: what if two nodes are down?
  if get_peer_status | grep -q rejected ; then
    echo "a peer is rejectd"
    rejected_node=$(get_peer_status | grep rejected | cut -d',' -f1)
    yes y | gluster volume remove-brick "$VOLUME" replica 2 "${rejected_node}:${BRICK}" force
    yes y | gluster peer detach "$rejected_node"
  fi

  # this is all under the assumption we have three worker nodes. This can be
  # modified to handel other cases, I have just chosen to take the easy way
  # out.
  if [[ $(get_peer_status | grep -c in_cluster) -ne 2 ]]; then
    # if we do not have the expected number of peers (3 minus this node, 2),
    # naivly attemp to peer with all nodes. This makes no effort to handle
    # peers that are marked as rejects (becuase they rebooted).
    gluster peer probe w1.dmz.509ely.com
    gluster peer probe w2.dmz.509ely.com
    gluster peer probe w3.dmz.509ely.com
  fi


  # to cretae a volume, I need two bricks, this one, and at least one peer.
  if [[ $(peer_count) -ge 1 ]] && [[ -z "$(gluster volume info)" ]]; then
    echo "creating volume"
    ps=$(get_peer_status)
    echo "Peer status:"
    echo "$ps"

    node=$(echo "$ps" | grep in_cluster | shuf -n1 | cut -d',' -f1)
    # the `force` is needed to suppress a warning that 'Replica 2 volumes are
    # prone to split-brain.'
    gluster volume create \
      "$VOLUME" \
      replica 2 \
      "$(hostname -f):$BRICK" \
             "${node}:$BRICK" \
             force
    gluster volume start "$VOLUME"
  fi

  # something something if [ peer count > brick

  # holy moly fragile string matching
  nodes_in_cluster=$(gluster volume info | grep -P "Brick\d: " | cut -d' ' -f2 | cut -d':' -f1)
  node_to_add=$(get_peer_status | cut -'d', -f1 | grep -v -f <(echo "$nodes_in_cluster")) || true

  if [[ -n "$node_to_add" ]]; then
    gluster volume add-brick "$VOLUME" replica 3 "${node_to_add}:${BRICK}"
  fi

  exit 0
}

main
