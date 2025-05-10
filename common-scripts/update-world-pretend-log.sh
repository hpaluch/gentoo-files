#!/bin/bash
set -xeuo pipefail
emerge -p --verbose --update-if-installed --deep --newuse  @world |
   tee /var/log/packages/update-world-`date '+%Y%m%d-%H%M'`.log
exit 0
