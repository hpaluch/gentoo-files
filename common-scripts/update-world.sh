#!/bin/bash
set -xeuo pipefail
emerge --ask --verbose --update-if-installed --deep --newuse "$@" @world
exit 0
