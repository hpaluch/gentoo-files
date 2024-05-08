
Pending Desktop X11 profile using:
- Stage: /srv/gentoo/UNI-WL2/stage3-amd64-desktop-openrc-20240414T161904Z.tar.xz
- Profile: ` [23]  default/linux/amd64/23.0/desktop (stable) *` 

Additional packages:
- removed `vlc` (blocked latest ffmpeg)
- installed

```
emerge -an net-misc/yt-dlp
emerge -an media-video/celluloid
emerge -an sys-apps/inxi x11-apps/xdpyinfo x11-apps/xdriinfo x11-misc/wmctrl x11-apps/mesa-progs app-admin/hddtemp sys-apps/dmidecode dev-util/vulkan-tools
emerge -an x11-misc/vdpauinfo x11-apps/xvinfo
```

BPF:
```
emerge -an dev-util/bcc
dispatch-conf
emerge -an dev-util/bcc

Required:
 * Messages for package dev-util/bcc-0.29.1-r1:

 *   CONFIG_BPF_SYSCALL:         is not set when it should be.
 *   CONFIG_NET_CLS_BPF:         is not set when it should be.
 *   CONFIG_NET_ACT_BPF:         is not set when it should be.
 *   CONFIG_BPF_EVENTS:  is not set when it should be.
 *   CONFIG_DEBUG_INFO:  is not set when it should be.
 *   CONFIG_FUNCTION_TRACER:     is not set when it should be.
 * Please check to make sure these options are set correctly.
 * Failure to do so may cause unexpected problems.
```

For: `dev-debug/bpftrace` also this options is needed
```
*   CONFIG_FTRACE_SYSCALLS:     is not set when it should be.
```

See [kernels/linux-6.6.30-gentoo/bpf_defconfig](kernels/linux-6.6.30-gentoo/bpf_defconfig) for
example with above BPF support.

NOTE: It should be possible to revalidate required kernel CONFIG options with `-p`, e.g.:
```shell
emerge -p dev-util/bcc
emerge -p dev-debug/bpftrace
```

