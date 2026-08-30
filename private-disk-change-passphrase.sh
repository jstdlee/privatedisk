#!/bin/sh
set -eu

IMG="${HOME}/private.img"
TARGET="${HOME}/private"
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

[ -f "$IMG" ] || {
    printf '%s\n' "Private Disk: missing ${IMG}" >&2
    exit 1
}

if [ -L "$TARGET" ] || [ -e "$TARGET" ]; then
    "${SCRIPT_DIR}/private-disk-unmount.sh" || exit 1
fi

printf '%s\n' "Enter the current passphrase, then choose the new passphrase twice."
cryptsetup luksChangeKey "$IMG"
printf '%s\n' "Passphrase changed. Use the mount launcher when needed."
