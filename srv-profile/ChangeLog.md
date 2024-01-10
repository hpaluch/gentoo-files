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

