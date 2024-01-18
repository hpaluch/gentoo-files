# ChangeLog for Gentoo SRV (Server) installation

2024-01-10:
* build host: `AMD Athlon(tm) 64 X2 Dual Core Processor 3800+`, 8GB RAM, HDD Iron Wolf
* globally enabled use `caps`
* `emerge-webrsync`
* `emerge --ask --verbose --update-if-installed --deep --newuse @world`
  - rebuild of 14 packages, including glibc (caused by update, so I used oportunity
    and also globally enabled 'caps')
  - notable: `sys-libs/glibc-2.37-r7` ->  `sys-libs/glibc-2.38-r9`
  - full list from `qlop`
    ```
    sys-libs/glibc: 44′44″
    sys-kernel/installkernel-gentoo: 17s
    sys-apps/coreutils: 4′44″
    app-admin/sysstat: 51s
    sys-apps/util-linux: 4′42″
    app-crypt/pinentry: 58s
    dev-libs/libuv: 1′09″
    net-misc/iputils: 33s
    app-misc/pax-utils: 33s
    sys-auth/pambase: 20s
    app-misc/resolve-march-native: 25s
    sys-apps/portage: 56s
    sys-apps/iproute2: 1′44″
    sys-devel/binutils: 5′45″
    ``` 
* added new packages:
  ```shell
  # to serve binary packages to Gentoo "clients"
  sudo emerge -an www-servers/lighttpd
  sudo qlop

  acct-group/lighttpd: 13s
  dev-libs/xxhash: 23s
  acct-user/lighttpd: 13s
  app-arch/brotli: 50s
  app-eselect/eselect-lua: 14s
  dev-lang/lua: 33s
  www-servers/lighttpd: 1′33″

  # reverse copy configuration file
  x=etc/lighttpd/lighttpd.conf
  diff buildserver/$x /$x
  sudo cp buildserver/$x /$x

  # only on build server run:
  sudo rc-update add lighttpd default
  sudo /etc/init.d/lighttpd start
  # you should see list of local binary packages
  lynx http://`hostname -f`/packages/
  ```
* installed additional commands
  ```shell
  emerge -an strace ltrace
  ```

2024-01-15:
* build host: Azure `Standard E4bds v5 (4 vcpus, 32 GiB memory)`, 32GB RAM, HDD (?)
* `emerge-webrsync`
* `emerge --ask --verbose --update-if-installed --deep --newuse @world`
* 18 packages
* rebuild of GCC, because flag `nptl` was removed from package.
* build times from qlop (N=New, U=Update, R=Replace (due USE changes, etc...)):
  ```
  qlop -EtH -d today

  N    app-crypt/libmd-1.1.0: 24 seconds
    U  dev-python/ensurepip-setuptools-69.0.3 [69.0.2]: 4 seconds
    U  dev-libs/libxml2-2.11.5-r1 [2.11.5]: 35 seconds
  N    sys-apps/lsb-release-3.2: 4 seconds
    U  dev-lang/python-3.12.1_p1 [3.12.1]: 2 minutes, 17 seconds
  N    dev-libs/libbsd-0.11.7-r2: 17 seconds
  N    app-eselect/eselect-rust-20210703: 7 seconds
    U  dev-vcs/git-2.43.0 [2.41.0]: 1 minute, 24 seconds
    U  sys-apps/shadow-4.14.2 [4.13-r4]: 30 seconds
    U  dev-python/setuptools-69.0.3 [69.0.2-r1]: 8 seconds
    U  dev-python/jinja-3.1.3 [3.1.2]: 7 seconds
  
    # Replaced -j2 with -j4 to use all 4 vCPUs:
  
   R   sys-devel/gcc-13.2.1_p20230826: 54 minutes, 31 seconds
  N    dev-lang/rust-bin-1.74.1: 34 seconds
  N    virtual/rust-1.74.1: 3 seconds
    U  sys-block/thin-provisioning-tools-1.0.6 [0.9.0-r2]: 45 seconds
    U  sys-fs/lvm2-2.03.22-r3 [2.03.21-r1]: 42 seconds
    U  sys-apps/portage-3.0.61-r1 [3.0.59-r1]: 16 seconds
    U  www-servers/lighttpd-1.4.72 [1.4.71]: 22 seconds
  ```

2024-01-18:
* build host: Azure `Standard E4bds v5 (4 vcpus, 32 GiB memory)`, 32GB RAM, HDD (?)
* `emerge-webrsync`
* `emerge --ask --verbose --update-if-installed --deep --newuse @world`

* build times from qlop (N=New, U=Update, R=Replace (due USE changes, etc...)):
  ```shell
  qlop -EtH -d today
   U  sys-libs/libseccomp-2.5.5 [2.5.4]: 19 seconds
    U  app-misc/ca-certificates-20230311.3.95 [20230311.3.93]: 9 seconds
    U  sys-apps/coreutils-9.4 [9.3-r3]: 1 minute, 23 seconds
    U  sys-apps/lsb-release-3.3 [3.2]: 4 seconds
    U  sys-apps/less-643-r1 [633]: 14 seconds
    U  app-admin/sudo-1.9.15_p4 [1.9.15_p2]: 39 seconds
    U  www-servers/lighttpd-1.4.73 [1.4.72]: 24 seconds
  N    dev-python/sphinxcontrib-jquery-4.1: 5 seconds
  N    dev-python/sphinx-rtd-theme-2.0.0: 7 seconds
    U  sys-fs/btrfs-progs-6.6.3 [6.6.2]: 29 seconds
  D    dev-libs/boost-1.82.0-r1: 2 seconds
  D    dev-build/b2-4.10.1: 1 second
  N    sys-power/acpid-2.0.34-r1: 9 seconds
  ```
- added `emerge -an sys-power/acpid` so "ACPI Shutdown" in VirtualBox works.
- on target you have to also enable service with `rc-update add acpid default`
  
