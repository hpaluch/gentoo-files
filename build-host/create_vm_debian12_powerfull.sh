#!/bin/bash

set -ue -o pipefail
# Your SubNet ID
subnet=/subscriptions/x/resourceGroups/x/providers/Microsoft.Network/virtualNetworks/x/subnets/FrontEnd 
# path to your public SSH key
ssh_key_path=`pwd`/hp2_key.pub
shutdown_email='your@email'

rg=GentooBuilderRG
loc=germanywestcentral
vm=hp-deb4gentoo-builder
IP=$vm-ip
opts="-o table"
# URN from command:
# az vm image list --all -l germanywestcentral -f debian-12 -p debian -s 12-gen2 -o table
image=Debian:debian-12:12-gen2:latest

set -x
az group create -l $loc -n $rg $opts
az network public-ip create -g $rg -l $loc --name $IP --sku Basic $opts
# WARNING! Always use "size" with "d" to have temporary storage!
# NOTE: 2^ power for os-disk-size-gb, because according to tooltip
# Azure always bill whole disk class (for 30GB it will bill 32GB)
az vm create -g $rg -l $loc \
    --image $image  \
    --nsg-rule NONE \
    --subnet $subnet \
    --public-ip-address "$IP" \
    --storage-sku Premium_LRS \
    --size Standard_E4d_v5 \
    --os-disk-size-gb 64 \
    --ssh-key-values $ssh_key_path \
    --admin-username azureuser \
    -n $vm $opts
az vm auto-shutdown -g $rg -n $vm --time 2100 --email "$shutdown_email" $opts
set +x
cat <<EOF
You may access this VM in 2 ways:
1. using Azure VPN Gateway 
2. Using Public IP - in such case you need to add appropriate
   SSH allow in rule to NSG rules of this created VM
EOF
exit 0

