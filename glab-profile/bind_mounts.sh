#!/bin/bash
set -xeuo pipefail

umount /mnt
mount /dev/sdb1 /srv/gentoo/AZ-GLAB/var/tmp

cd `dirname $0`
mount --types proc /proc `pwd`/proc
mount --rbind /sys `pwd`/sys
mount --rbind /dev `pwd`/dev
mount --bind  /run `pwd`/run
exit 0
