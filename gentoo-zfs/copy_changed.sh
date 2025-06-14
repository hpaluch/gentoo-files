#!/bin/sh

set -eu
cd `dirname $0`

# expected hostname
e_h=gentoo-zfs

h=$(hostname)
[ "x$h" = "x$e_h" ] || {
	echo "Wrong machine: '$h' <> '$e_h'" >&2
	exit 1
}

root=''
for i in `find etc var -type f | sort`
do
	echo "comparing: '$i'"
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
