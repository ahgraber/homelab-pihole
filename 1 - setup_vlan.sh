#!/bin/bash
# script to set up 'default' vlan config for pihole

########################
###   set up vlans   ###
########################
sudo apt install vlan

### update network interfaces
# WARNING: this will overwrite and replace /etc/network/interfaces.d/interfaces!
# make backup if file exists
[ -f "/etc/network/interfaces.d/interfaces" ] \
    && sudo cp /etc/network/interfaces.d/interfaces \
    /etc/network/interfaces.d/interfaces.old

# create vlan interfaces
echo \
"auto lo
iface lo inet loopback

#auto eth0.86
#iface eth0.86 inet static
#vlan-raw-device eth0
#address 10.0.3.14 
#network 10.0.0.0/22
#broadcast 10.0.0.255

auto eth0.10
iface eth0.10 inet static
vlan-raw-device eth0
address 10.1.3.14 
network 10.1.0.0/22
broadcast 10.1.0.255

auto eth0.20
iface eth0.20 inet static
vlan-raw-device eth0
address 10.2.3.14 
network 10.2.0.0/16
broadcast 10.2.0.255

auto eth0.30
iface eth0.30 inet static
vlan-raw-device eth0
address 10.3.3.14 
network 10.3.0.0/20
broadcast 10.3.0.255
" \
| sudo tee /etc/network/interfaces.d/interfaces


### update dnsmasq
# make backup if file exists
[ -f "/etc/dnsmasq.d/99-interfaces.conf" ] \
    && cp /etc/dnsmasq.d/99-interfaces.conf /etc/dnsmasq.d/99-interfaces.conf.old
sudo cp /etc/network/interfaces.d/interfaces /etc/network/interfaces.d/interfaces.old

echo \
"
#interface=eth0.86  # this is the native vlan
interface=eth0.10
interface=eth0.20
interface=eth0.30
" \
| sudo tee /etc/dnsmasq.d/99-interfaces.conf


### Cleanup & Reminders ###
echo "Have you trunked the switch port to the pi???"
echo "Pihole is rebooting..."
sudo reboot