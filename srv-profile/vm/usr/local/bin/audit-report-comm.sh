#!/bin/bash
set -xeuo pipefail
sudo aureport -ts boot --comm -i "$@"
exit 0
