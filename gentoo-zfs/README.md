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

