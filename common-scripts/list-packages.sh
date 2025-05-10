#!/bin/bash
set -xeuo pipefail
[ -d /var/log/packages ] || mkdir -p /var/log/packages
equery l '*' | tee /var/log/packages/all-packages-`date '+%Y%m%d-%H%M'`.log
exit 0
