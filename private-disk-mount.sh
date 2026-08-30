#!/bin/sh
set -eu

IMG="${HOME}/private.img"
TARGET="${HOME}/private"

die() {
    printf '%s\n' "Private Disk: $*" >&2
    exit 1
}

mount_path() {
    udisksctl info --block-device "$1" 2>/dev/null \
        | awk -F: '/MountPoints:/ {sub(/^[[:space:]]*/, "", $2); print $2; exit}'
}

[ -f "$IMG" ] || die "missing ${IMG}"

LOOP="$(udisksctl loop-setup --file "$IMG" \
    | sed -n 's/.* as \(\/dev\/loop[0-9][0-9]*\)\./\1/p')"
[ -n "$LOOP" ] || die "could not create a loop device"

UUID="$(cryptsetup luksUUID "$IMG")"
DM="/dev/mapper/luks-${UUID}"

if [ ! -e "$DM" ]; then
    printf '%s\n' "Enter the private-disk passphrase when prompted."
    udisksctl unlock --block-device "$LOOP"
fi

MOUNT="$(mount_path "$DM")"
if [ -z "$MOUNT" ]; then
    udisksctl mount --block-device "$DM"
    MOUNT="$(mount_path "$DM")"
fi
[ -n "$MOUNT" ] || die "could not determine the filesystem mount path"

if [ -L "$TARGET" ]; then
    [ "$(readlink "$TARGET")" = "$MOUNT" ] || die "${TARGET} is a symlink to another path"
elif [ -e "$TARGET" ]; then
    [ -d "$TARGET" ] || die "${TARGET} exists and is not a directory"
    [ -z "$(find "$TARGET" -mindepth 1 -maxdepth 1 -print -quit)" ] \
        || die "${TARGET} is not empty; refusing to replace it"
    rmdir "$TARGET"
    ln -s "$MOUNT" "$TARGET"
else
    ln -s "$MOUNT" "$TARGET"
fi

printf 'Mounted at %s\n' "$TARGET"
