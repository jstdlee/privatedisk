#!/bin/sh
set -eu

IMG="${HOME}/private.img"
TARGET="${HOME}/private"
SIZE="${PRIVATE_DISK_SIZE:-500G}"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

die() {
    printf '%s\n' "Private Disk: $*" >&2
    exit 1
}

[ ! -e "$IMG" ] || die "${IMG} already exists; refusing to overwrite it"

printf 'Creating a new %s LUKS2 image at %s\n' "$SIZE" "$IMG"
fallocate -l "$SIZE" "$IMG"
chmod 600 "$IMG"

printf '%s\n' "Choose the passphrase when cryptsetup prompts below."
cryptsetup luksFormat --type luks2 "$IMG"

LOOP="$(udisksctl loop-setup --file "$IMG" \
    | sed -n 's/.* as \(\/dev\/loop[0-9][0-9]*\)\./\1/p')"
[ -n "$LOOP" ] || die "could not create a loop device"

udisksctl unlock --block-device "$LOOP"
UUID="$(cryptsetup luksUUID "$IMG")"
DM="/dev/mapper/luks-${UUID}"
DM_OBJECT="$(udisksctl info --block-device "$DM" \
    | sed -n '1s/:$//p')"
[ -n "$DM_OBJECT" ] || die "could not find the unlocked filesystem object"

gdbus call --system \
    --dest org.freedesktop.UDisks2 \
    --object-path "$DM_OBJECT" \
    --method org.freedesktop.UDisks2.Block.Format \
    ext4 "{'label': <'private'>}" >/dev/null
gdbus call --system \
    --dest org.freedesktop.UDisks2 \
    --object-path "$DM_OBJECT" \
    --method org.freedesktop.UDisks2.Filesystem.TakeOwnership \
    "{}" >/dev/null

"${SCRIPT_DIR}/private-disk-mount.sh"
printf '%s\n' "Initialization complete. The filesystem is available at ${TARGET}."
