#!/bin/bash
set -xeuo pipefail
cd `dirname $0`
env -i HOME=/root TERM=$TERM /usr/sbin/chroot . /bin/su --login
exit 0
