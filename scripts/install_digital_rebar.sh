#!/usr/bin/env bash
set -euo pipefail

# this scripts get and configures digital rebar [1] [2] which we use as the
# configration and provisioning server for the home lab. DR handles DNS and
# tftp.
#
# [1] https://rebar.digital/
# [2] https://github.com/digitalrebar/provision

install_prereqs_if_needed() {
  PREREQS=(git jq)

  need_to_install="false"
  for pkg in "${PREREQS[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      need_to_install="true"
    fi
  done

  if [ $need_to_install == "true" ]; then
    sudo apt update -y
    sudo apt install -qy ${PREREQS[*]}
  fi
}

install_drb() {
  DRP_DIR="/opt/drp"
  sudo mkdir -p "$DRP_DIR"
  pushd "$DRP_DIR"
  curl -fsSL get.rebar.digital/stable | sudo bash -s -- install
}

install_prereqs_if_needed

# todo: is this a valid check?
if ! systemctl is-active --quiet dr-provision; then
  install_drb
fi

sudo drpcli autocomplete /etc/bash_completion.d/drpcli

drpcli bootenvs uploadiso sledgehammer
drpcli prefs set defaultWorkflow discover-base unknownBootEnv discovery
drpcli contents upload catalog:task-library-stable
drpcli bootenvs uploadiso ubuntu-18.04-install
drpcli bootenvs uploadiso debian-9-install


###
#  EXAMPLE - please modify the below values according to your environment  !!!
###

network_config=$(mktemp)
cat << EOF > "$network_config"
{
  "Name": "dmz",
  "Subnet": "10.24.90.0/24",
  "ActiveStart": "10.24.90.100",
  "ActiveEnd": "10.24.90.254",
  "ActiveLeaseTime": 60,
  "Enabled": true,
  "ReservedLeaseTime": 7200,
  "Strategy": "MAC",
  "Options": [
    { "Code": 3, "Value": "10.24.90.1", "Description": "Default Gateway" },
    { "Code": 6, "Value": "8.8.8.8", "Description": "DNS Servers" },
    { "Code": 15, "Value": "dmz.509ely.com", "Description": "Domain Name" }
  ]
}
EOF

drpcli subnets create - < "$network_config" || true # todo: check if the subnet exists


debian_boot_env=$(mktemp)
cat << EOF > "$debian_boot_env"
{
  "Name": "ubuntu-1804lts",
  "Family": "ubuntu",
  "Codename": "",
  "Version": "18.04lts",
  "IsoFile": "",
  "IsoSha256": "",
  "IsoUrl": "",
  "SupportedArchitectures": {
    "x86_64": {
      "IsoFile": "mini.iso",
      "Sha256": "9a2c47d97b9975452f7d582264e9fc16d108ed8252ac6816239a3b58cef5c53d",
      "IsoUrl": "http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso",
      "Kernel": "images/pxeboot/vmlinuz",
      "Initrds": [
        "images/pxeboot/initrd.img"
      ],
      "BootParams": "ksdevice=bootif ks={{.Machine.Url}}/compute.ks method={{.Env.InstallUrl}} inst.geoloc=0 {{.Param \"kernel-options\"}} -- {{.Param \"kernel-console\"}}",
      "Loader": ""
    }
  }
}
EOF

drpcli bootenvs create - < "$debian_boot_env" || true # todo: check if the subnet exists
