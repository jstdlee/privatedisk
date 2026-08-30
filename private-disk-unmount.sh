#!/bin/sh
set -eu

IMG="${HOME}/private.img"
TARGET="${HOME}/private"

[ -f "$IMG" ] || exit 0

LOOP="$(udisksctl loop-setup --file "$IMG" \
    | sed -n 's/.* as \(\/dev\/loop[0-9][0-9]*\)\./\1/p')"
UUID="$(cryptsetup luksUUID "$IMG")"
DM="/dev/mapper/luks-${UUID}"

if [ -L "$TARGET" ]; then
    LINK="$(readlink "$TARGET")"
    case "$LINK" in
        /media/"$USER"/*) rm "$TARGET" ;;
    esac
fi

udisksctl unmount --block-device "$DM" >/dev/null 2>&1 || true
udisksctl lock --block-device "$LOOP" >/dev/null 2>&1 || true
printf '%s\n' "Private disk unmounted and locked."
