#!/bin/sh
set -eu

IMG="${HOME}/private.img"
TARGET="${HOME}/private"

[ -f "$IMG" ] || {
    printf '%s\n' "Private Disk: missing ${IMG}" >&2
    exit 1
}

if [ -L "$TARGET" ] || [ -e "$TARGET" ]; then
    "${HOME}/dev/privatedisk/private-disk-unmount.sh" || exit 1
fi

printf '%s\n' "Enter the current passphrase, then choose the new passphrase twice."
cryptsetup luksChangeKey "$IMG"
printf '%s\n' "Passphrase changed. Use the mount launcher when needed."
