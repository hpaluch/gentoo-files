#!/bin/bash
set -euo pipefail

cd `dirname $0`
rsync -av --delete -e ssh az-vm:/srv/gentoo/AZ-SRV/var/cache/binpkgs az-srv
exit 0

