#!/bin/bash

set -eu
cd `dirname $0`

declare -A host2root
host2root[hp-deb4gentoo-srv2]=/srv/gentoo/ROOT-SRV
host2root[x2-gentoo-srv.example.com]=/

h=$(hostname -f)
root="${host2root[$h]:-NULL}"
[ "x$root" != "xNULL" ] || {
	echo "ERROR: FQDN '$h' not found in associative array 'host2root'" >&2
	exit 1
}

echo "Using Gentoo root='$root'"
[ -d "$root" ] || {
	echo "ERROR: Invalid root '$root' is not directory" >&2
	exit 1
}

gf=$root/etc/portage/make.conf

[ -f "$gf" ] || {
	echo "ERROR: Gentoo file '$gf' not found or not file" >&2
	exit 1
}

for i in `find etc -type f`
do
	src="$i"
	src=$(echo "$src" | sed 's/dot\././')
	if [ "$i" = "./.gitignore" ]; then
		continue
	fi

	[ -f "$root/$src" ] || {
		echo "WARN: File '$root/$src' does not exist - IGNORED"
		continue;
	}

	[ -r "$root/$src" ] || {
		echo "WARN: File '$root/$src' unreadable - IGNORED"
		ls -l "$root/$src"
		continue;
	}

	#echo "'$src' -> '$i'"
	diff --color=always -u "$i" "$root/$src" || {
		echo -n "File $i changed - copy [y/N]?"
		read ans
		case "$ans" in
			y*|Y*)
				cp -v	"$root/$src" "$i" 
				;;
			*)
				echo "Copy Skipped"
				;;
		esac
	}
done
exit 0
