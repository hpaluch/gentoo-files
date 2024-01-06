# Gentoo Files

## Future profiles

* [srv-profile/](srv-profile/) - my Gentoo profiles for CLI Servers. Work in progress!

## Current Profiles

* [gui-profile/](gui-profile/) - actively used Desktop profile with X11 (Xfce4) and
  Wayland (Sway) and standard apps (Firefox, Chromium, LibreOffice, virt-manager,...)

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

