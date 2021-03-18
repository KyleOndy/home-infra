#!/bin/bash
#TYPE=$1
#NAME=$2
STATE=$3
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
