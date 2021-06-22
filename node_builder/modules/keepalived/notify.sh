#!/bin/bash
#TYPE=$1
#NAME=$2
STATE=$3

# todo: I stop traefik to avoid multipule instances accessing acme.json. Since
#       all trafic shuld be comming in via the VIP, I shouldn't have to stop
#       trafeik, but is this still a good practice?
case $STATE in
        "MASTER") systemctl start traefik
                  ;;
        "BACKUP") systemctl stop traefik
                  ;;
        "FAULT")  exit 0
                  ;;
        *)        exit 1
                  ;;
              esac
