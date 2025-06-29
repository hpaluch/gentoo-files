# Gentoo Files

> [!WARNING]
>
> In the past I used gcc parameter `-fno-strict-aliasing` to _avoid_ pointer aliasing
> bugs but it turned to do opposite: it causes crash in glibc backtrace(3) call and
> possible other bugs.
>
> If you used it - remove it immediately from `/etc/portage/make.conf` and rebuild
> glibc with `emerge -a1v sys-libs/glibc`.
>
> See also https://bugs.gentoo.org/955635

## Future profiles

* [gentoo-zfs/](gentoo-zfs) - Gentoo installed on ZFS with XFCE DE
* [glab-profile/](glab-profile/) - GitLab profile - Experimental!
* [srv-profile/](srv-profile/) - my Gentoo profiles for CLI Servers. Work in progress!
* [nomulti-profile/](nomulti-profile/) - no multilib (64-bit only) profile - Work  in progress!

## Current Profiles

* Feb 2025: [gui-plasma/](gui-plasma/) - KDE Plasma/Wayland (tested on KVM VM, planned copy
  on old AMD X2 machine.

* [gui-profile/](gui-profile/) - actively used Desktop profile with X11 (Xfce4) and
  Wayland (Sway) and standard apps (Firefox, Chromium, LibreOffice, virt-manager,...)

## Build Server

Most of time I use host Debian 12 Linux with Gentoo chroot as build server to create
binary packages. I use one of: Azure VM or spare computer at work. In case of Azure
I simply install in Host (Debian) Nginx and acquire trusted certificate from Let's
Encrypt using `certbot`. There is nice guide on:
- https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04
- https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-11
That's is also valid for Debian.

See [build-host/](build-host/) for scripts used for build server.

You can find details in:
- [gui-profile/server/](gui-profile/server/) - build server for my GUI Gentoo installations
- [srv-profile/buildserver/](srv-profile/buildserver/) - build server for my future "Server" Gentoo
  installation.
- [hard-profile](hard-profile) - Gentoo Hardened - text only, planned server workload

Please note that in reality both build servers will be single Azure VM instance (chroots) hosted
on Debian 12 OS.


## Old profiles

They are under [old-gui-profile/](old-gui-profile/)

> It was my original GUI profile I used over Christmas. But I quickly found that maintaining
> 2 different build servers and targets is significant burden that simply does not scale.
>
> Therefore I started [gui-profile](gui-profile) which has only baseline optimizations
> enabled and works on both common AMD and Intel CPUs.

They are tailored for two CPU vendors (I have 2 bare metal boxes, each different vendor):
1. is AMD Opteron (2 cores)
2. is Intel Celeron (4 cores)

Please see also:
- https://github.com/hpaluch/hpaluch.github.io/wiki/Gentoo
- https://github.com/hpaluch/hpaluch.github.io/wiki/Gentoo-setup

When available I use build server for Gentoo binary packages and installing them
on later on target (which is not so much powerful).

I have to make intersection of available CPU features on build server and target computer.

Here are coresponding folders:
* [amd/](amd/)

