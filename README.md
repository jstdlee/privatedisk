# Private Disk

Small Linux helpers for unlocking and mounting a LUKS2-encrypted disk image
with a passphrase.

The scripts expect:

`${HOME}/private.img` — a LUKS2 image
`${HOME}/private` — the user-facing mount path

`private-disk-init.sh` creates a new 500 GiB LUKS2 image, prompts for a
passphrase, and refuses to overwrite an existing image. Set
`PRIVATE_DISK_SIZE` to choose another size.

`private-disk-mount.sh` prompts for the passphrase through `udisksctl`, mounts
the filesystem through UDisks, and exposes its UDisks mount point at
`${HOME}/private`. `private-disk-unmount.sh` unmounts and locks it.
`private-disk-change-passphrase.sh` changes the LUKS passphrase.

Required commands include `cryptsetup`, `udisksctl`, `gdbus`, `fallocate`,
`awk`, `sed`, `find`, and `readlink`.

These helpers intentionally do not contain a passphrase, keyfile, disk image,
machine identifier, or user-specific absolute path. Keep encrypted images and
keyfiles outside this repository.
