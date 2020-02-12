# Home Lab

[//]: # ( why monorepo? )
This repository is a monorepo containing all the code and scripts to build out my "production" homelab.
This lab actaully hosts things exposed to the public internet, so I treat it with some respect.

## Overview

### Hardware

This lab consists of seven nodes.
Three RaspberryPi 4 nodes run as masters.
Three oDriod h2s as worker nodes.
A RaspberryPi3(?) as a utility node.

All these nodes sit on a flat network.

The 3 master nodes are powered via PoE.
This means they are tied into the UPS and can stay up during short power outages.
The worker nodes and utility node are powerd directly from mains and will go down with any power outage.

[//]: # ( why into its own vlan? )
Future plans may invlolve splitting storage traffic onto its own vlan.

### Software

#### Hashistack

Consil
Nomad
Vault
Concourse
Storage (ceph vs glusterFS)
MinIO
Trafeik
Ubuntu

## Bootstrapping

All nodes are bootstapped by installing ubuntu 18.04LTS via PXE boot.
Once the base OS is installed, a set of ansible scripts configures the rest.
Everything is written with the intnetion that the cluster can be in various bad states.
This is acomplished by treating none of the data within this cluster as truely stateful.
In the worst case senerio I bebuild from scratch and restore data from the latest backup.

The worker nodes are booted fresh via PXE every boot.
I do not write a bootloader to them.


### Steps from scratch

Everything starts with the utility node.
This can be anything.
I just happen to use an old RaspberryPi I had around.

- Install Raspbain onto an SD card with the rasbian_to_sd.sh script.
- Clone this repo into some working direcroty on the utility node.
- Run the bootstrap.sh script

This script will start a handful of docker images that take care of the following.

- PXE boot server to image the nodes
- Regularrly running ansbile against these nodes to keep configuration upto date.
- Running the initial copy of `cacheNg` to keep things qucik.

#### New RaspberryPis

Out of the box a RP is not setup to boot from the network.

- Write Raspbian to SD card.
- Boot Pi.
- ssh pi@host_or_ip "bash -s" -- < ./scripts/enable_pxe
