#!/bin/bash
set -exuo pipefail
# workaround for fatal error: [drm:vmw_du_cursor_plane_atomic_check [vmwgfx]] *ERROR* surface not suitable for cursor
# see: https://github.com/swaywm/sway/issues/5834
WLR_NO_HARDWARE_CURSORS=1 sway
exit 0
