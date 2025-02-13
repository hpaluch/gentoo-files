#!/bin/bash

set -eu
cd `dirname $0`/tree

root=/

gf=$root/etc/portage/make.conf

[ -f "$gf" ] || {
	echo "ERROR: Gentoo file '$gf' not found or not file" >&2
	exit 1
}

for i in `find etc var -type f`
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
