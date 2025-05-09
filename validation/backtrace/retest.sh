#!/bin/bash
set -xeuo pipefail
cd $(dirname $0)
make clean all && ./backtrace
exit 0

