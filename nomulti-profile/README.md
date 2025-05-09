# Gentoo nomulti profile

Profile for pure 64-bit gentoo (=nomultilib)

Profile characteristics:
* OpenRC (no systemd)
* only text-mode supported
* no sound (or other HW) support

Our main guide is:
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation#Networking_information


Tested under VM (LibVirt/KVM)

On host:
- download ISO:
  ```shell
  curl -fLO https://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal/install-amd64-minimal-20250429T205022Z.iso
  ```
- and boot it with maximum number of CPUs and Memory (I use 8 cores, 16GB RAM, host has 12 threads and 32GB RAM)
- on VM enable SSHD:
  ```shell
  passwd # password for remote login
  /etc/init.d/sshd start
  # print VM IP address
  ip -br -4 a
  ``` 
- start logging and connect from Host to VM:
  ```shell
  script install-nomulti.log
  ssh root@VM_IP
  ```

Now on VM we have to partition disk and prepare filesystem:
```shell
fdisk /dev/vda

g # create GPT partition table
n # new partition
1 # No. 1
Start: 2048
Last Sector: +2m
t # change Type
4 # BIOS boot = GRUB in BIOS mode
n # new partition
2 # No. 2
First sector: 6144
Last sector: +800m
t # change type
2 # No. 2
1 # EFI boot = GRUB boot in EFI mode
n # new partition
3 # No. 3
First sector: ENTER for default
Last sector: ENTER for default
p # to print,example:

Device       Start      End  Sectors  Size Type
/dev/vda1     2048     6143     4096    2M BIOS boot
/dev/vda2     6144  1644543  1638400  800M EFI System
/dev/vda3  1644544 67106815 65462272 31.2G Linux filesystem

v # verify
w # write and quit

# now back in shell do:
mkfs.vfat -n GENTOO_EFI /dev/vda2
mkfs.btrfs -L gentoo-btrfs /dev/vda3
```

Now we will prepare BTRFS - create subvolume and remount:
```shell
mount /dev/vda3 /mnt/gentoo/
# create subvolume "root1" - target for gentoo
cd /mnt/gentoo
mkdir 00GENTOO-TOP-VOL # "label" top BTRFS volume
btrfs su cr root1 # create subvol "root1" - our target
mkdir root1/00ROOT1-SUBVOL # to "label" "root1" subvolume
# remount subvol and check:
umount /mnt/gentoo 
mount -o subvol=root1,compress=zstd /dev/vda3 /mnt/gentoo/
ls -l /mnt/gentoo/00ROOT1-SUBVOL/ # must be there - proof that mounted subvol=root1
```

From your host copy several useful scripts:
```shell
# Host PC with this repository
cd THIS_DIR
scp bind_mounts.sh enter_chroot.sh init_shell.sh root@VM_IP:/mnt/gentoo
```


Now we can bootstrap filesystem:
```shell
cd /mnt/gentoo
curl -fLO https://ftp.fi.muni.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-openrc/stage3-amd64-nomultilib-openrc-20250504T164008Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# I just note used stage for future reference:
touch root/stage3-amd64-nomultilib-openrc-20250504T164008Z.tar.xz.stamp
rm stage3-*.tar.xz

# standard preparation:
cp -L /etc/resolv.conf etc # dereference links
mkdir -p etc/portage/repos.conf
./bind_mounts.sh
# Now ENTERS chroot!
./enter_chroot.sh
# Updates profile and setups chroot prompt:
source  /init_shell.sh
```

Now inside chroot:
```shell
emerge-webrsync
eselect profile list | fgrep '*'

# expected output:  [29]  default/linux/amd64/23.0/no-multilib (stable) *

# I no longer use these, but they may be useful:
emerge -an app-portage/cpuid2cpuflags app-misc/resolve-march-native
# gentoo provides "euse" and other commands
emerge -an app-portage/gentoolkit

# Now copy these files from this Repository:
...


# NOTE: I use --update-if-installed  instead of plain --update to
# avoid installing inused but updated packages
emerge --ask --verbose --update-if-installed --deep --newuse @world

# Timezone stuff
cd /etc && ln -sf ../usr/share/zoneinfo/UTC /etc/localtime
emerge --config sys-libs/timezone-data
date # must show UTC
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

# boot loader
# WARNING! os-prober or grub with "device-mapper" has dependency on llvm bloat
emerge -an sys-boot/grub sys-boot/os-prober

# edit /etc/default/grub and:
# uncomment: GRUB_CMDLINE_LINUX="net.ifnames=0"
# uncomment: GRUB_TERMINAL=console

# run on target OUTSIDE CHROOT:
genfstab -U /mnt/gentoo/ >> /mnt/gentoo/etc/fstab

# run on target only:
grub-install /dev/sdX

# on real target (NOT CHROOT!) you can do:
echo 'sys-kernel/installkernel dracut grub' > /etc/portage/package.use/installkernel
emerge -an sys-kernel/installkernel

# building kernel sources
cd /usr/src/linux
cp /THIS_REPO/kernels/srv_defconfig /usr/src/linux/arch/x86/configs
make srv_defconfig
make menuconfig
make -j`nproc` && make modules_install && make install

# tools required for new system
emerge -an net-misc/dhcpcd app-admin/rsyslog app-admin/sudo
cp vm/etc/rsyslog.d/* /etc/rsyslog.d/

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

# RSyslog

First:
```shell
emerge -an app-admin/rsyslog
rc-update add rsyslog default
cp vm/etc/rsyslog.d/ /etc/rsyslog.d/
/etc/init.d/rsyslog start
```

# Enabling audit

Following:
- https://github.com/hpaluch/hpaluch.github.io/wiki/Audit
- https://wiki.gentoo.org/wiki/Audit

```shell
# do only once:
emerge -an sys-process/audit
cp vm/etc/audit/rules.d/*.rules /etc/audit/rules.d/
cp vm/usr/local/bin/*.sh /usr/local/bin
rc-update add auditd default
/etc/init.d/auditd start

# after all rules change:
augenrules --load
auditctl -l
```

