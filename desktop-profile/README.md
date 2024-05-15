
Pending Desktop X11 profile using:
- Stage: /srv/gentoo/UNI-WL2/stage3-amd64-desktop-openrc-20240414T161904Z.tar.xz
- Profile: ` [23]  default/linux/amd64/23.0/desktop (stable) *`

# Installing NVidia GT218 firwmare

Tested on NVidia GT218, Nouveau driver. If your `dmesg` shows messages like:
```
kernel: Loading firmware: nouveau/nva8_fuc084
kernel: nouveau 0000:06:00.0: Direct firmware load for nouveau/nva8_fuc084 failed with error -2
kernel: Loading firmware: nouveau/nva8_fuc084d
kernel: nouveau 0000:06:00.0: Direct firmware load for nouveau/nva8_fuc084d failed with error
```
You will need to install NVidia proprietary firmware. However required package is masked.

To unmask it we have to follow: https://wiki.gentoo.org/wiki/Knowledge_Base:Unmasking_a_package

```shell
touch /etc/portage/package.accept_keywords/zzz_autounmask
emerge sys-firmware/nvidia-firmware --autounmask-write --autounmask
dispatch-conf
emerge -an sys-firmware/nvidia-firmware
find /lib/firmware/ -name nva8\*

  /lib/firmware/nouveau/nva8_fuc085
  /lib/firmware/nouveau/nva8_fuc084
  /lib/firmware/nouveau/nva8_fuc086
``

Installed this version:
```shell
$ equery l sys-firmware/nvidia-firmware

[IP-] [  ] sys-firmware/nvidia-firmware-340.32-r1:0
```
Note that version 340 is last one that support my GT218 card.

After installation reboot system and check with `dmesg` that there is no error when loading firmware.

One way to verify that firmware was loading is to see Video acceleration support using `vdpauinfo`
from package `x11-misc/vdpauinfo`.

Here is impressive curated list for my GT218 card:
```shell
$ vdpauinfo | sed -n '/^Decoder capabilities/,/Output/p' | fgrep -v 'not supported'

Decoder capabilities:

name                        level macbs width height
----------------------------------------------------
MPEG1                           0  8192  2048  2048
MPEG2_SIMPLE                    3  8192  2048  2048
MPEG2_MAIN                      3  8192  2048  2048
H264_BASELINE                  41  8192  2048  2048
H264_MAIN                      41  8192  2048  2048
H264_HIGH                      41  8192  2048  2048
VC1_SIMPLE                      1  8190  2048  2048
VC1_MAIN                        2  8190  2048  2048
VC1_ADVANCED                    4  8190  2048  2048
MPEG4_PART2_SP                  3  8192  2048  2048
MPEG4_PART2_ASP                 5  8192  2048  2048
H264_CONSTRAINED_BASELINE      41  8192  2048  2048
```

If list is empty - there was likely error loading firmware or Xorg driver.

Additionally EGL should start working, but not yet. Output from `inxi -G --display`:

```
Graphics:
  Device-1: NVIDIA GT218 [GeForce 210] driver: nouveau v: kernel
  Display: server: X.Org v: 21.1.13 driver: X: loaded: nouveau
    unloaded: modesetting,vesa dri: nouveau gpu: nouveau
    resolution: 1440x900~60Hz
  API: EGL v: 1.4,1.5 drivers: nouveau,swrast
    platforms: gbm,x11,surfaceless,device
  API: OpenGL v: 3.3 vendor: mesa v: 24.0.4 renderer: NVA8
  API: Vulkan Message: No Vulkan data available.
```

When I start `mpv -vo=gpu ~/Videos/VIDEO.mp4` there is still error:
```
libEGL warning: failed to get driver name for fd -1
libEGL warning: MESA-LOADER: failed to retrieve device information
libEGL warning: failed to get driver name for fd -1
```
But there is promising answer on:
https://stackoverflow.com/questions/72110384/libgl-error-mesa-loader-failed-to-open-iris
- suggesting to try older "mesa-amber". On Gentoo:

```shell
emerge -an media-libs/mesa-amber
```

It helped! Errors is gone and CPU load dropped to each-core: 25% (from 75%). Please note that
this acceleration stops working in full-screen mode (when you press `F`) for some reason.

What is strange, that `inxi -G --display` reports `EGL: no data available` - I think that is is because
only older APIs are supported...

WARNING! It has opposite effect on real Arch-Linux (graphics will be slow to crawl) - because Arch
Linux does not allow coexistence of new Mesa and Mesa-amber (we need 3D graphics support for Window Manager
but older Mesa for video playback...)

# Others

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

NOTE: It should be possible to revalidate required kernel CONFIG options using
trick from https://forums.gentoo.org/viewtopic-t-1110538-start-0.html
```shell
ebuild $(equery w dev-util/bcc) setup clean
ebuild $(equery w dev-debug/bpftrace) setup clean
```
WARNING! `pkg_pretend()` in `*.ebuild` has nothing common with `emerge -p` (emerge pretend). It is
confusing coincidence...

