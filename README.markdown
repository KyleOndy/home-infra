# 509 Ely

> :warning: I makes *no* effort to encourage reusability outside of this repository.
> Copy and paste at your own risk.

This is the mono-repository that contains the code and assets to build, run, and manage my home infrastructure.

## Purpose and Intent

At this time I am not writing any code with the express intent of being consumed in a wider context.

Unlike at my job, I allow myself to disregard typical concerns of software development.
This allows me to iterate quick, over-engineer less, and actually ship something, even its its not "the right way".

This also allows me to push my boundaries of what I am comfortable doing.

The primary motivator of this lab is to learn, sometimes the hard way, about the underlaying services.
From layer 1 to layer 7 I own it and control it.

This is not a reference architecture.
I throw `--force` and `yes | <foo>` with reckless abandonment.
This whole thing is glued together with some questionable `bash` scripts.
The result is tangible though.
Real workloads run on this cluster, some are even exposed externally.

Here is an incomplete list of services being hosted out of the cluster.
If the service is down, hey, I probably broke it.

- [kyleondy.com](https://www.kyleondy.com)
- [git.ondy.org](https://git.ondy.org)

### The sharp edges

I've chosen to approach this lab as a collection of ephemeral nodes.
Treating each deployment as an immutable collection of artifacts (`initrd`, `vmlinuz`, and `ramroot.tar.xz`) remove the need for any configuration management.

Since there is no persisted state outside of this cluster if I lose quorum, data is *gone*.
Even with this cluster sitting on a UPS, on occasion my residential power feed goes down for a few hours.
I do not store any data that is irreplaceable on this cluster.

## Overview

This home-lab is comprised of seven nodes.

```
Host  Hardware            RAM   Disk       Purpose
util  _Old_ raspberry pi  1G    16G (sd)   Network Boot, NFS Host
m1    Raspberry Pi 4      4G    32G (sd)   Master Node, Consul, Nomad
m2    Raspberry Pi 4      4G    32G (sd)   Master Node, Consul, Nomad
m3    Raspberry Pi 4      4G    32G (sd)   Master Node, Consul, Nomad
w1    ODRIOD H2           32G   1T  (nvme) Nomad client
w2    ODRIOD H2           32G   1T  (nvme) Nomad client
w3    ODRIOD H2           32G   1T  (nvme) Nomad client
```

The three master nodes are treated like pets right now.
I have an ongoing effort to network boot them in the `rpi_network_boot` branch.
This will allow me to treat the master as disposable.

### So how does it work

This section needs to be expanded, but a high level overview is as follows.

- create work node image with the [`make_node`](./node_builder/make_node) script.
- move the artifacts to the utility node with [`sync_util_node`](./scripts/sync_util_node)
- utility node runs network boot infrastructure: [`run.sh`](./util-node/run.sh)
- the worker node network  boots and joins the cluster
- deploy some nomad jobs from the [`jobs`](./jobs) folder.

### Errors

#### `run-qemu.sh`

```
qemu: linux kernel too old to load a ram disk
```

Check that you didn't mix up the kernel and ramdisk.

```
# when ipxe trying to download files:
exec format error
```
The `vmlinuz` **must not** be compressed.

Thanks to *travislazar* for his [post on formum.ipxe.org](https://forum.ipxe.org/showthread.php?tid=18153&pid=34902#pid34902) that shed light on this one. It was a dark period before I found this.






```
machince gets PXE info, downloads preboot(?) env.
Preboot env wgets(?) the ramroot image
boot the ramroot image with some fancy magic, and into running os
```

## General Workflow

- ./scripts/install_rasbian
- ssh pi@<ip_of_new_node> "bash -s" < ./scripts/bootstrap_rasbian_node
    - password: `raspberry`

        VMLINUZ CAN NOT BE COMPRESSEDk

## Things still done manually

- Setting up Dynmaic DNS is unifi
- Setting up DNS in Namecheap

## External Links

These repositioes, blog posts, and other resources all helped me get to where I am.

- [Medallia's `ramroot` project](https://github.com/medallia/ramroot)
- [Install `dockerx`](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/)
- [Euan Kemp (euank) suggesting to use ipxe](https://github.com/danderson/netboot/issues/119#issuecomment-703434559)
- [Euan Kemp (euank) MR to add arm64 suppoer to netboot](https://github.com/danderson/netboot/pull/121)
- [guide](https://brennan.io/2019/12/04/rpi4b-netboot/)
