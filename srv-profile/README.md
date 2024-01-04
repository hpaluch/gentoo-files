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

I use Host VM on Debian 12 in Azure. Here is example script to create such VM in Azure Shell:
- WARNING! Script below attempts to use low price (and low power) VM - you can use better resources
  if you have enough money...
```shell
#!/bin/bash

set -ue -o pipefail
# Your SubNet ID
subnet=/subscriptions/xxxxx/resourceGroups/xxxxx/providers/Microsoft.Network/virtualNetworks/xxxxx/subnets/xxxxx 
ssh_key_path=`pwd`/your_ssh_key.pub
shutdown_email='your_email@your_domain'

rg=GentooSrvRG
loc=germanywestcentral
vm=hp-deb4gentoo-srv
IP=$vm-ip
opts="-o table"
# URN from command:
# az vm image list --all -l germanywestcentral -f debian-12 -p debian -s 12-gen2 -o table
image=Debian:debian-12:12-gen2:latest

set -x
az group create -l $loc -n $rg $opts
az network public-ip create -g $rg -l $loc --name $IP --sku Basic $opts
az vm create -g $rg -l $loc \
    --image $image  \
    --nsg-rule NONE \
    --subnet $subnet \
    --public-ip-address "$IP" \
    --storage-sku Standard_LRS \
    --size Standard_B2ms \
    --os-disk-size-gb 30 \
    --ssh-key-values $ssh_key_path \
    --admin-username azureuser \
    -n $vm $opts
az vm auto-shutdown -g $rg -n $vm --time 2200 --email "$shutdown_email" $opts
set +x
cat <<EOF
You may access this VM in 2 ways:
1. using Azure VPN Gateway 
2. Using Public IP - in such case you need to add appropriate
   SSH allow in rule to NSG rules of this created VM
EOF
exit 0
```

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

