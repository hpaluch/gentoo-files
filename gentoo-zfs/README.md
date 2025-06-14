# Gentoo on ZFS

Gentoo installed on ZFS. Mostly following: https://wiki.gentoo.org/wiki/ZFS/rootfs

You have to use "Admin CD" or "Live GUI" ISO - only these has ZFS support in kernel. I used:

```shell
curl -fLO https://distfiles.gentoo.org/releases/amd64/autobuilds/20250525T165446Z/livegui-amd64-20250525T165446Z.iso
```

My installation disk is `/dev/vda`. I use hybrid boot (GPT with both 'BIOS Grub' and 'EFI', so it can be booted
on both old BIOS and new UEFI machines):

```shell
fdisk /dev/vda

Command (m for help): g
Created a new GPT disklabel (GUID: F99746C4-C2DB-4608-A88F-8BCD7152D6B2).

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-83886046, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-83886046, default 83884031): +2m

Created a new partition 1 of type 'Linux filesystem' and of size 2 MiB.

Command (m for help): t
Selected partition 1
Partition type or alias (type L to list all): 4
Changed type of partition 'Linux filesystem' to 'BIOS boot'.

Command (m for help): n
Partition number (2-128, default 2): 
First sector (6144-83886046, default 6144): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6144-83886046, default 83884031): +768m

Created a new partition 2 of type 'Linux filesystem' and of size 768 MiB.

Command (m for help): t
Partition number (1,2, default 2): 2
Partition type or alias (type L to list all): 1

Changed type of partition 'Linux filesystem' to 'EFI System'.

Command (m for help): n
Partition number (3-128, default 3):
First sector (1579008-83886046, default 1579008):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (1579008-83886046, default 83884031):

Created a new partition 3 of type 'Linux filesystem' and of size 39.2 GiB.

Command (m for help): p

Disk /dev/vda: 40 GiB, 42949672960 bytes, 83886080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: F99746C4-C2DB-4608-A88F-8BCD7152D6B2

Device       Start      End  Sectors  Size Type
/dev/vda1     2048     6143     4096    2M BIOS boot
/dev/vda2     6144  1579007  1572864  768M EFI System
/dev/vda3  1579008 83884031 82305024 39.2G Linux filesystem

Command (m for help): v

No errors detected.
Header version: 1.0
Using 3 out of 128 partitions.
A total of 2015 free sectors is available in 1 segment.

Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Next prepare empty EFI (don't used on my setup):
```shell
mkfs.vfat -n GENTOO_EFI /dev/vda2
```

ZFS setup (from Wiki):
```shell
zpool create -f -o ashift=12 -o autotrim=on  -o compatibility=openzfs-2.1-linux \
	-O acltype=posixacl  -O xattr=sa  -O relatime=on  -O compression=lz4 \
	-m none tank /dev/vda3
zfs create -o mountpoint=none tank/os
zfs create -o mountpoint=/ -o canmount=noauto tank/os/gentoo
zfs create -o mountpoint=/home tank/home
zpool set bootfs=tank/os/gentoo tank
zpool export tank
zpool import -N -R /mnt/gentoo tank
zfs mount tank/os/gentoo
zfs mount tank/home
mount -t zfs
```

```shell
$ df -h

Filesystem      Size  Used Avail Use% Mounted on
devtmpfs         10M     0   10M   0% /dev
tmpfs           7.9G     0  7.9G   0% /dev/shm
tmpfs           7.9G   44M  7.8G   1% /run
/dev/sr0        3.6G  3.6G     0 100% /run/initramfs/live
/dev/loop0      3.5G  3.5G     0 100% /run/rootfsbase
LiveOS_rootfs   7.9G   44M  7.8G   1% /
tmpfs           1.6G   28K  1.6G   1% /run/user/1000
tmpfs           1.6G     0  1.6G   0% /run/user/0
tank/os/gentoo   38G  128K   38G   1% /mnt/gentoo
tank/home        38G  128K   38G   1% /mnt/gentoo/home
```

Stage3:
```shell
cd /mnt/gentoo
curl -fLO https://ftp.linux.cz/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-20250608T165347Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

Cloning my repo (Live GUI CD has `git` command):
```shell
cd /mnt/gentoo/root
git clone https://github.com/hpaluch/gentoo-files.git
# copy chroot scripts:
cp gentoo-files/chroot-scripts/standard/*.sh /mnt/gentoo
( cd gentoo-files/gentoo-zfs/etc/portage && find . type f | cpio -pvdm /mnt/gentoo/etc/portage/ )
cp gentoo-files/gentoo-zfs/etc/locale.gen /mnt/gentoo/etc
```

Entering chroot:
```shell
cd /mnt/gentoo
./bind_mounts.sh # do this only once
./enter_chroot.sh
source /init_shell.sh
```

TODO: setup mostly from https://github.com/hpaluch/hpaluch.github.io/wiki/Gentoo-setup


ZFS notes:

- kernel must have enabled Compression -> Deflate for ZFS module
- before using Dracut you have to create `/etc/dracut.conf.d/zol.conf` with contents (from Wiki):

  ```
  nofsck="yes"
  add_dracutmodules+=" zfs "
  ```

- before emerging GRUB ensure that you enabled `libzfs` - in my case I have
  in `/etc/portage/package.use/custom`:

  ```
  sys-boot/grub libzfs
  ```

- have to enable service to mount all other datasets than root:

  ```shell
  rc-update add zfs-mount default
  ```


Main system tools:
```shell
emerge -an sys-fs/ncdu app-portage/gentoolkit app-editors/vim app-misc/mc app-admin/sudo \
  app-misc/tmux app-admin/sysstat sys-apps/smartmontools \
  net-misc/dhcpcd app-admin/rsyslog sys-process/cronie app-shells/bash-completion \
  sys-process/lsof
```

