# Home infra

## Architecture

All nodes are within `10.25.89.0/24`.

From my sysadmin days I prefer to use DHCP reservations.
However, to avoid making any configuration here appear magic, I've resigned to assign nodes static IPs.

The DHCP range is set to `10.25.89.201 - 10.24.89.255`.

All master nodes are homogeneous.
RaspberryPi 4 4Gb.

| m1 (10.25.89.11) | m2 (10.25.89.12) | m3 (10.25.89.13) |
| -----------------|------------------|------------------|
| keepalived       | keepalived       | keepalived       |
| k3s master       | k3s master       |                  |
| vault master     | vault master     | vault master     |
|                  |                  | postgres db      |
|                  |                  |                  |

All worker nodes are homogeneous.
[ODRIOD H2](https://www.hardkernel.com/shop/odroid-h2/) with 32gb ram and 500GB nvme.

| m1 (10.25.89.21) | m2 (10.25.89.22 | m3 (10.25.89.23) |
| -----------------|-----------------|------------------|
| keepalived       | keepalived      | keepalived       |
| k3s worker       | k3s worker      | k3s worker       |

keepalived provides the following two virtual IPs

- `10.25.89.9`:  k3s masters
- `10.25.89.10`: master nodes
- `10.25.89.20`: worker nodes

## Process

### Step 0: Initial bootstrap

Base base infrastructure configured and built out

- k3s
  - keepalived
  - postgres
- vault

## Roadmap

### Be able to diff remote running closure and closure to deploy

You can `sshfs` the remote system and `nix store diff-closures <generate> <mount/run/current-system>`

## External Links

[deploy-rs](https://github.com/serokell/deploy-rs/)
[nixos](https://nixos.org/)

### k3s

[using external datastore](https://rancher.com/docs/k3s/latest/en/installation/datastore/)
[embedded ha](https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/)
