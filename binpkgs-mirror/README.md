# binpkgs mirrors

Here are scripts that I use to synchronize Gentoo binary packages from Azure
build server to my local machine. I then put these folders to my NAS (that
exposes them over http).

Finally I emerge (with `-gk` appended) on clients from that NAS.
Clients has to have file `/etc/portage/binrepos.conf/gentoobinhost.conf` with contents like:

```ini
[gentoobinhost]
priority = 1
#sync-uri = https://gentoo.osuosl.org/releases/amd64/binpackages/17.1/x86-64
sync-uri = URL_TO_BINARY_PACKAGES
```

NOTE: You have to comment out original `sync-uri` to avoid official (systemd!) Gentoo
binary packages which were introduced just recently...


