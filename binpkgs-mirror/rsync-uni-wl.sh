#!/bin/bash
set -euo pipefail

cd `dirname $0`
rsync -av --delete -e ssh az-vm:/srv/gentoo/UNI-WL/var/cache/binpkgs uni-wl
exit 0

