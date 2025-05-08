#!/bin/bash
set -xeuo pipefail
sudo ausearch -ts boot -i "$@"
exit 0
