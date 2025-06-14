#!/bin/sh
# add system file to this repository
set -euo pipefail

[ $# -gt 0 ] || {
	echo "Usage: $0 file1 ... " >&2
	exit 1
}

for i in "$@"
do
	[ -f "$i" ] || {
		echo "ERROR: pathname '$i' is not file" >&2
		exit 0
	}
	case "$i" in
		/*)
			: # OK
			;;
		*)
			echo "ERROR: pathname '$i' must start with '/'" >&2
			exit 1
			;;
	esac
	d="$(dirname "$i")"
	td=".$d"
	[ -d "$td" ] || mkdir -pv "$td"
	tf=".$i"
	[ ! -f "$tf" ] || {
		echo "ERROR: target file '$tf' already exists" >&2
		exit 1
	}
	cp -v "$i" "$tf"
done

exit 0
