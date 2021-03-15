legacy() {


  # do this early so if there is a GPG error it fails fast
  # todo: could this be passed in a node boot time with an boot arg?
  # todo: renable this
  # todo: pass in a boot arg?
  # ENCRYPT_KEY=${CONSUL_ENCRYPT_KEY:-"$2"}



  # todo: go back to `--varient=minbase` to save more space.
  # todo: move from eoan -> focal once docker is supported.

  # note: debain wasn't supported on my x86 boards
  # todo: once nix's debootstrap package is updated, use focal instead of eoan

  debootstrap_packages=(
    # core system package. Without these system will not boot
    locales
    initramfs-tools
    linux-generic # todo: is -generic the right choice?

    # basic dev tools. These tools are available for the sake of installion
    #                  script.
    #software-properties-common
    curl
    openssh-server # it will boot, but I like remote access
    parted
    rsync
    tar

    # debugging / util. These increase size, and are not nessacary to boot or build the image, but are nice to have.
    glances # system monitoring
    htop    # ligherwirght monitoring
    mosh    # better ssh
    neovim  # text editing

    # application specific
    # todo: should thier own scripts handle installing these?
    # gettext-base    # needed for envsubst, in consul install
    # keepalived      # used for poor mans load balanceer
    # nfs-common      # for NFS share, used by traefik

    # these need to be verified that they are required
    # ca-certificates
    # gpg-agent
    # pixz
    # xfsprogs
  )

  # todo: it would be nice to add the option to reuse an existing debootstap and
  #       not just blindly recreate one. While this behavior is nice to ensuring
  #       purity, it does take a bit of time.
  log "Running debootstrap"
  debootstrap \
    --variant=fakechroot \
    --arch=amd64 \
    --components=main,universe \
    --cache-dir="$DEB_BOOTSTRAP" \
    "--include=${debootstrap_packages[*]}" \
    focal \
    "$CHROOT_DIR" \
    http://archive.ubuntu.com/ubuntu/

  cp -r "$SCRIPT_DIR"/initramfs-tools/* "$CHROOT_DIR/etc/initramfs-tools/"



  # todo: enable and make this work
  #run_script_in_chroot "$SCRIPT_DIR/modules/glusterfs/install"

  #run_script_in_chroot <(echo "
  ## doing some basic setup
  #locale-gen 'en_US.UTF-8'
  #update-locale LANG=en_US.UTF-8
  #
  ## this is used so I can fact check what build I am running
  #echo \"$(git rev-parse HEAD)\" > /etc/node-build-rev
  #echo \"$BUILD_TIMESTAMP\" > /etc/node-build-date
  #
  ## I had an issue where the scripts in '/etc/initramfs-tools/hooks' seemed to be
  ## silently ignored. It was becuase the scripts were not executbale.
  #chmod -R 755 /etc/initramfs-tools/
  #
  ## add ssh key for easier management
  ## todo: this should be injected in and not hard-coded
  #mkdir -p /root/.ssh
  #cat << SSH >> /root/.ssh/authorized_keys
  #ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZq6q45h3OVj7Gs4afJKL7mSz/bG+KMG0wIOEH+wXmzDdJ0OX6DLeN7pua5RAB+YFbs7ljbc8AFu3lAzitQ2FNToJC1hnbLKU0PyoYNQpTukXqP1ptUQf5EsbTFmltBwwcR1Bb/nBjAIAgi+Z54hNFZiaTNFmSTmErZe35bikqS314Ej60xw2/5YSsTdqLOTKcPbOxj2kulznM0K/z/EDcTzGqc0Mcnf51NtzxlmB9NR4ppYLoi7x+rVWq04MbdAmZK70p5ndRobqYSWSKq+WDUAt2+CiTm6ItDowTLuo3zjHyYV1eCnB35DdakKVldIHrQyhmhbf5hJi6Ywx6XCzlFoNpkl/++RrJT2rf0XpGdlRoLQoKFvNRfnO4LI499SIfFb9Pwq7LhF1C1kTmshN/9S44d6VCCYXLE4uS8OPv7IXxUvFQZaIKCbomd2FzXxUwf4lg2gSlczysgDaVsMAUvlfDVgTFX8Xt1LFl3DqNtUiUpa9+Jnst/jCqqOBf3e8= kyle@alpha
  #SSH
  #")
  #
  ## make sure we are running the latest security updates
  ## todo: this doesn't work
  ##run_script_in_chroot <(echo "
  ##apt-get -q update
  ##apt-get -yq dist-upgrade
  ##")
  #
  #run_script_in_chroot "$SCRIPT_DIR/modules/consul_agent/install" "$ENCRYPT_KEY"
  #run_script_in_chroot "$SCRIPT_DIR/modules/nomad_agent/install"
  #run_script_in_chroot "$SCRIPT_DIR/modules/scheduled_reboot/install"
  #
  ## todo: install this the real way
  #run_script_in_chroot <(echo "
  #curl -fsSL https://get.docker.com | sh
  #")
  #
  ## keep alive lets me have a floating IP between all worker nodes
  #run_script_in_chroot "$SCRIPT_DIR/modules/keepalived/install"
  #
  ## I install traefik as a system service so I can easily bind to the floating IP. Initally I tried to run this under nomad for the flexibility, but had trouble getting nomad to work correctly with a floating IP.
  #run_script_in_chroot "$SCRIPT_DIR/modules/traefik/install"

  # doing some last housekeeping and cleanup
  run_script_in_chroot <(echo "
  echo 'root:root' | chpasswd # todo: pull from password manager
  echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

  # this is what builds the updated initrd to network boot with. It will run the
  # scripts in /etc/initramfs-tools.
  update-initramfs -cu
  ")
  #
  ## setup mount points
  #cp "$SCRIPT_DIR/../files/format-scratch.service"  "$CHROOT_DIR/etc/systemd/system/"
  #cp "$SCRIPT_DIR/../files/scratch-local.mount"     "$CHROOT_DIR/etc/systemd/system/"
  #cp "$SCRIPT_DIR/../files/mnt-nfs.mount"           "$CHROOT_DIR/etc/systemd/system/"
  #run_script_in_chroot <(echo "
  #systemctl enable format-scratch
  #systemctl enable scratch-local.mount
  #systemctl enable mnt-nfs.mount
  #")

  umount "$CHROOT_DIR/proc" "$CHROOT_DIR/sys"

  # future: this can be split into two separate process to generate the
  # kerne;/initramfs and the process to create the rootramfs. This would allow
  # easier updating on one or the other. For now, simplicity wins.
  # todo: symlink these?
  # todo: which versions do I really need?
  cp --dereference "$CHROOT_DIR"/boot/vmlinuz-* "$OUT_DIR/"
  ln -rs "$OUT_DIR/vmlinuz"* "$OUT_DIR/vmlinuz"

  cp --dereference "$CHROOT_DIR"/boot/initrd.img-* "$OUT_DIR/"
  ln -rs "$OUT_DIR/initrd.img-"* "$OUT_DIR/initrd.img"

  # now that we have generated the initrd and kerenl, we can remove files that
  # are not needed within the ramFS.
  rm -fr "$CHROOT_DIR/tmp/*"
  rm -fr "$CHROOT_DIR/var/cache" # is this safe?
  rm "$CHROOT_DIR"/boot/vmlinuz-*
  rm "$CHROOT_DIR"/boot/initrd.img-*

  # now getting risky...
  # These modules aren't used on my board, but I should comment these out if I
  # seem to be having weird runtime issues.
  rm -fr "$CHROOT_DIR"/usr/lib/firmware/netronome
  rm -fr "$CHROOT_DIR"/usr/lib/firmware/liquidio
  rm -fr "$CHROOT_DIR"/usr/lib/firmware/amdgpu
  rm -fr "$CHROOT_DIR"/usr/lib/modules/5.3.0-18-generic/kernel/drivers/net/wireless

  pushd "$CHROOT_DIR" > /dev/null && {
    # todo: I feel like there should be an easier way to do this.
    tar -cf "$WORK_DIR/ramroot.tar" .
  }
  popd > /dev/null

  # This can take a while. Write to a temp file before copying it over to the
  # outfolder so its not in an intermediate state for too long.
  pixz "-$PIXZ_COMPRESSION_LEVEL" < "$WORK_DIR/ramroot.tar" > "$WORK_DIR/ramroot.tar.xz"



  cp "$WORK_DIR/ramroot.tar.xz" "$OUT_DIR/ramroot.tar.xz"

  # set the permissions on the artifacts so they can be consumed by a normal user.
  chown -R "kyle" "$OUT_DIR"
  chmod -R 755 "$OUT_DIR"
}
