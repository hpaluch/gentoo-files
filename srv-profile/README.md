# Gentoo Server profile

Here are my files I use to setup Gentoo Server.
There are two kinds of machines:

* buildserver - builds and offers binpkgs for targets
* target(s) - will consume binpkgs

Profile characteristics:
* OpenRC (no systemd)
* only text-mode supported
* no sound (or other HW) support

Our main guide is:
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Networking_information

# Build server setup

On Host (Debian 12):
```shell
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install curl tmux vim jq mc lynx git
mkdir -p /srv/gentoo/ROOT-SRV
cd /srv/gentoo
curl -fLO http://ftp.linux.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64-openrc/stage3-amd64-openrc-20231231T163203Z.tar.xz
cd ROOT-SRV
tar xpvf ../stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
# recommended - mount /srv/gentoo/ROOT-SRV/var/tmp/ on fast disk 
cd /srv/gentoo/ROOT-SRV
# NOTE: prepated etc/make.conf
cp -L /etc/resolv.conf etc/
mkdir --parents etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
# Copy these files from git to /srv/gentoo/ROOT-SRV
# - buildserver/bind_mounts.sh buildserver/init_shell.sh
# - buildserver/etc/portage/*
# TODO: ...
./bind_mounts.sh
tmux
chroot `pwd` bash
# inside chroot:
source /init_shell.sh
```
In chroot:
```shell
emerge-webrsync
eselect profile list
# using:   [1]   default/linux/amd64/17.1 (stable) *
# Not needed: eselect profile set 1

# TODO:
# gentoo provides "euse" and other commands
emerge -an app-portage/gentoolkit
emerge --ask --verbose --update --deep --newuse @world
```

