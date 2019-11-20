#!/usr/bin/env bash

rsync -avrP $HOME/src/home-infra kyle@10.24.90.21: && ssh kyle@10.24.90.21 "/home/kyle/home-infra/bootstrap/bootstrap.sh"
