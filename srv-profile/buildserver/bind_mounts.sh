#!/bin/bash
set -xeuo pipefail

cd `dirname $0`
mount --types proc /proc `pwd`/proc
mount --rbind /sys `pwd`/sys
mount --rbind /dev `pwd`/dev
mount --bind  /run `pwd`/run
exit 0
