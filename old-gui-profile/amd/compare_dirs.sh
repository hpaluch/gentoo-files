#!/bin/bash
set -euo pipefail
cd `dirname $0`
diff -ru az-buildserver/etc/ x2/etc/
exit 0
