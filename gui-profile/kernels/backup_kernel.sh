#!/bin/bash
set -euo pipefail

d=/var/local

ver_file=/usr/src/linux/include/config/kernel.release

[ -r "$ver_file" ] || {
	echo "ERROR: '$ver_file' not readable" >&2
	exit 1
}

ver=`cat $ver_file | tr -d '\r\n'`

[ -n "$ver" ] || {
	echo "ERROR: Unable to extract kernel version from $ver_file" >&2
	exit 1
}

m=/lib/modules/$ver
[ -d "$m" ] || {
	echo "ERROR: '$m' is not directory" >&2
	exit 1
}

( cd /usr/src/linux && make savedefconfig && cp defconfig /boot/${ver}_defconfig )

t=$d/gentoo-kernel-bin-$ver-`date '+%s'`.tar.gz
tar cvzf $t -C / boot/${ver}_defconfig boot/{System.map,config,vmlinuz}-$ver \
   boot/initramfs-$ver.img lib/modules/$ver
exit 0

