#!/usr/bin/env bash

echo "[-] Disabling network interfaces..."
systemctl stop network-manager
killall -9 dhclient

for network_interface in $(ifconfig | grep -iEo '^[a-z0-9]+:' | grep -v '^lo:$' | cut -d ':' -f 1) 
do
	ifconfig "$network_interface" 0.0.0.0 down
done 