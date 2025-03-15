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

Here is script that I run in Azure Shell UI:
- [../build-host/create_vm_debian12_powerfull.sh](../build-host/create_vm_debian12_powerfull.sh)


On Host (Debian 12):
```shell
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install curl tmux vim jq mc lynx git
mkdir -p /srv/gentoo/ROOT-SRV
cd /srv/gentoo
curl -fLO https://ftp.linux.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64-openrc/stage3-amd64-openrc-20250309T170330Z.tar.xz
cd ROOT-SRV
tar xpvf ../stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
# If you are using Azure VM with temporary disk under /mnt you can do this:
sudo umount /mnt
sudo mount /dev/disk/cloud/azure_resource-part1 /srv/gentoo/ROOT-SRV/var/tmp
# WARNING! Do not modify /etc/fstab - cloud-init will overwrite it on boot...

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
# eselect profile list | fgrep '*'
#  [21]  default/linux/amd64/23.0 (stable) *
# no need for change 23.0 = year 2023 revision 0


# I no longer use these, but they may be useful:
emerge -an app-portage/cpuid2cpuflags app-misc/resolve-march-native
# gentoo provides "euse" and other commands
emerge -an app-portage/gentoolkit

# NOTE: I use --update-if-installed  instead of plain --update to
# avoid installing inused but updated packages
emerge --ask --verbose --update-if-installed --deep --newuse @world

# Timezone stuff - UTC recommended for servers
echo UTC > /etc/timezone
emerge --config sys-libs/timezone-data
# Locales:
# copy buildserver/etc/locale.gen to chroot
# and run:
locale-gen
eselect locale list
# keeping:  [13]  C.UTF8 *
env-update && source /init_shell.sh
# Now preparing for kernel build:
emerge -an sys-kernel/linux-firmware
# the other packages are requierd for initramfs and/or boot:
emerge -an sys-kernel/gentoo-sources
# selecting kernel sources
eselect kernel list
eselect kernel set 1

# dracut and its dependencies
emerge -an sys-apps/pciutils sys-kernel/dracut \
  sys-fs/btrfs-progs sys-fs/lvm2 sys-fs/squashfs-tools

# building kernel sources
cd /usr/src/linux
cp /THIS_REPO/kernels/srv_defconfig /usr/src/linux/arch/x86/configs
make srv_defconfig
make menuconfig
make -j`nproc` && make modules_install && make install
### got weird crash:
###  scripts/link-vmlinux.sh: line 175: 137890 Aborted                 ${objtree}/scripts/sorttable ${1}
### Failed to sort kernel tables
### Workaround: commencted out call to sortable in scripts/link-vmlinux.sh


dracut --kver=`cat /usr/src/linux/include/config/kernel.release`

# boot loader
# WARNING! os-prober or grub with "device-mapper" has dependency on llvm bloat
emerge -an sys-boot/grub sys-boot/os-prober

# edit /etc/default/grub and:
# uncomment: GRUB_CMDLINE_LINUX="net.ifnames=0"
# uncomment: GRUB_TERMINAL=console

# run on target only:
grub-install /dev/sdX
# line below requires valid /etc/fstab
grub-mkconfig -o /boot/grub/grub.cfg

# tools required for new system
emerge -an net-misc/dhcpcd app-admin/rsyslog app-admin/sudo

rc-update add dhcpcd default
rc-update add rsyslog default
rc-update add sshd default

# run visudo and:
# append: Defaults !fqdn
# uncomment: %wheel ALL=(ALL:ALL) NOPASSWD: ALL

# optional but popular
emerge -an www-client/lynx sys-fs/ncdu app-portage/gentoolkit app-editors/vim app-misc/mc \
 app-misc/tmux app-admin/sysstat sys-apps/smartmontools \
 app-shells/bash-completion sys-process/lsof
# install Git so I can track changes in this repo...
emerge -an dev-vcs/git

# I often move installation around chroot <-> VM <-> bare metal
# so installing Guest tools (enable on apropriate target only)
# KVM guest: (excluding vdagent stuff that is for GUI)
emerge -an app-emulation/qemu-guest-agent
# only on Target KVM gust run:
rc-update add qemu-guest-agent default

passwd root
/usr/sbin/useradd -m -s /bin/bash -G wheel USERNAME
passwd USERNAME

```

General notes:
- use `dispatch-conf` to merge config changes in `/etc`

## Boostraping Buildserver Image to Target

Now we have to copy this Server filesystem to real Target.

First, still on build server, create backup tarball of Gentoo filesystem.
Using script `backup-chroot-srv.sh` with contents:
```shell
#!/bin/bash
set -xeuo pipefail
suffix=ROOT-SRV
root=/srv/gentoo/$suffix
sudo tar -cav --numeric-owner --one-file-system \
	--exclude=./var/cache/distfiles \
       	-f `dirname $0`/gentoo-$suffix-rootfs-`date '+%s'`.tar.zst -C $root .
exit 0
```
Run this script on Build server - it will produce tarball with name,
for example: `gentoo-ROOT-SRV-rootfs-1704555258.tar.zst`.

Now transfer this `.tar.zst` to place from where there will be reachable Target VM.

Now create Target VM, I used `virt-manager` (libvirt GUI) with these parameters:
- CPU: 2 (or more)
- Memory: 2GB (or more)
- Disk: 32GB, Virtio BLK (`/dev/vdaX`)
  - was 12GB, but some packages are really big (qemu that includes agent around 500MB + 1GB for build!)
- ISO image:
  - download: http://ftp.linux.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal/install-amd64-minimal-20231231T163203Z.iso
  - and point LibVirt to it.
- Machine: `Q35`
- Firmware: `BIOS`

Now boot target VM and do this:
- set root password with `passwd root`
- start SSH server using: `/etc/init.d/sshd start`
- now on you local machine I recommend this:
  ```shell
  script install.log # log installation to file
  ssh root@IP_OF_VM
  ```
- we will partition disk as GPT to make it dual-bootable under both BIOS and UEFI (in future).
  This scheme is used by many popular products (Ubuntu server, Proxmox VE, VMware ESXi,...)
- now we have to partition disk using:
  ```shell
  fdisk /dev/vda
  g # switch partition scheme to GPT
  n # create new partition
  default 1 # part number - press ENTER
  default 2048 # start sector (aligned to 1MB) - press ENTER
  +2M # size 2MB for BIOS GRUB
  t # change type
  BIOS boot # enter exactly that "BIOS boot" with space, without quotes
  n # new partition - EFI System Partition (ESP)
  default 2 # ENTER - confirm partition number
  default 6144 # starting sector - press enter
  +1g # size
  t # change type
  default 2 # ENTER to confirm partition number
  uefi # EFI ESP partition type, it wil tell 'EFI System'
  n # new partition (ext4 for root fs)
  default 3 # part number, press ENTER
  default 2103296 # start sector, press ENTER
  +29g # size (keeping free 2gb for swap)
  n # create new swap partition
  default 4 # press ENTER
  default X # press ENTER to confirm start
  default X # press ENTER to confirm end - should around 2GB
  t # change type
  swap # enter "swap" to change type to 'Linux swap'
  p # print partitions
  
  Device        Start      End  Sectors Size Type
  /dev/vda1      2048     6143     4096   2M BIOS boot
  /dev/vda2      6144  2103295  2097152   1G EFI System
  /dev/vda3   2103296 62920703 60817408  29G Linux filesystem
  /dev/vda4  62920704 67106815  4186112   2G Linux swap
  
  v # verify partitions
  w # write partition table to disk
  ```
- now format FAT32 ESP partition using:
  ```shell
  mkfs.fat -F 32 -N EFI_SYS /dev/vda2
  ```
- format ext4 for root filesystem:
  ```shell
  mkfs.ext4 -L gentoo-srv-root /dev/vda3
  ```
- finally format swap:
  ```shell
  mkswap -L gentoo-srv-swap /dev/vda4
  ```
- now mount future rootfs and swap:
  ```shell
  mount /dev/vda3 /mnt/gentoo/
  swapon /dev/vda4
  ```

Now you have to upload root fs tarball - .tar.zst to Gentoo VM, from your local
machine run command like:
```shell
scp gentoo-ROOT-SRV-rootfs-1704555258.tar.zst root@IP_OF_GENTOO_VM:/mnt/gentoo/
```

Back on Gentoo VM we have to unpack tarball:
```shell
cd /mnt/gentoo
tar xpf gentoo-ROOT-SRV-rootfs-1704555258.tar.zst
```

Before entering chroot we have to mount all required filesystems:
```shell
mkdir /mnt/gentoo/boot/efi
mount /dev/vda2 /mnt/gentoo/boot/efi
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
```

Now generate proper fstab using:
```shell
genfstab -U /mnt/gentoo > /mnt/gentoo/etc/fstab
```

Finally enter chroot!:
```shell
chroot /mnt/gentoo bash
# now you are in chroot:
source /etc/profile
export PS1="(VM ROOT-SRV) ${PS1}"
grub-install /dev/vda

grub-mkconfig -o /boot/grub/grub.cfg
# ensure that BOTH kernel and initrd found
```
You are now ready to exit chroot, unmount filesystems, and reboot.
```shell
Ctrl-d # exit chroot
cd / # allow unmounting gentoo fs
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
```

And watch your VM console - Target Gentoo system should boot normally.

Target post-configuration:
If you want to independently build packages also in Target you are finished.
But if you want to change Target to Consume packages from build server you need to:
- on Build Server publish `/var/cache/binpkgs/` over http(s) for Targets to download these binaries
- on Target:
  - edit `/etc/portage/binrepos.conf/gentoobinhost.conf` and
    change `sync-uri = ...` to URL of your Build Server with binary packages.
  - Swap these two lines in `/etc/portage/make.conf` so they look this way:
    ```shell
    # Client: do not fetch specified binary packages (use always source)
    EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --usepkg-exclude 'acct-*/* sys-kernel/*-sources virtual/*'"
    
    # Server: which Binary packages to NOT build:
    #EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --buildpkg-exclude  'acct-*/* sys-kernel/*-sources virtual/*'"
    ```
  - on Target always append `-GK` (to download only binaries from server), or
    relaxed `-gk` (to download binaries if available, but build otherwise - should be used when
    excluded packages have to be installed)

# After install

Please see dedicated [ChangeLog.md](ChangeLog.md) for updates and installations.

## Configure firewall

We will use simple configuration with nftables. I will combine
these two sources:
- https://wiki.gentoo.org/wiki/Nftables
- https://wiki.archlinux.org/title/nftables

First install packages:

```shell
emerge -an net-firewall/nftables
```

Next we need some rules
- using modified file from https://wiki.archlinux.org/title/nftables
- copy `THIS_REPO/target/etc/nftables.conf` to your Target's `/etc/`
- now validate rules with: `nft -cf /etc/nftables.conf`
- if OK, apply rules: `nft -f /etc/nftables.conf`
- now you have to Save rules using: `/etc/init.d/nftables save`
- finally we can enable nftables on startup: `rc-update add nftables default`

TODO: Configure Syslog-ng rules...


