#!/bin/bash
set -euo pipefail


# Found backing device
DEV=`awk '$2=="/mnt" {print $1}' /proc/mounts`

[ -n "$DEV" -a -b "$DEV" ] || {
        echo "ERROR: Unable to find backing device for /mnt" >&2
        exit 1
}
set -x
cd `dirname $0`
umount /mnt
mkfs.btrfs -L btrfs-tmp -f $DEV
mount -o compress=zstd,nodiscard $DEV var/tmp

cp -L /etc/resolv.conf etc/
mount --types proc /proc proc
mount --rbind /sys sys
mount --rbind /dev dev
mount --bind  /run run
exit 0

