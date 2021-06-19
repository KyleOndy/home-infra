# Node Builder

- generate_chroot
- provision_chroot
- unmount_chroot
- copy_chroot
- cleanup_chroot

## When things go wrong

`mount | rg /tmp/ | cut -d' ' -f3 | xargs -I{} -- sudo umount {}`

