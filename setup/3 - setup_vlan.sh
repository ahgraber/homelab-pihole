#!/bin/bash
# script to set up 'default' vlan config for pihole
# ref: https://engineerworkshop.com/blog/raspberry-pi-vlan-how-to-connect-your-rpi-to-multiple-networks/

# set ip
read -p "Please provide target IP (10.0.__.__): " IP

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
echo = \
'auto lo
iface lo inet loopback

allow-hotplug eth0
auto eth0
iface eth0 inet manual
'

# create vlan interfaces
echo = \
'# allow-hotplug eth0
# # VLAN 86 is native; does not need specification
# auto eth0
# iface eth0 inet manual
# address 10.0.'$IP'
# network 10.0.0.0/22
# broadcast 10.0.3.255

auto eth0.10
iface eth0.10 inet manual
  vlan-raw-device eth0
# address 10.1.'$IP'
# network 10.1.0.0/22
# broadcast 10.1.3.255

auto eth0.20
iface eth0.20 inet manual
  vlan-raw-device eth0
# address 10.2.'$IP'
# network 10.2.0.0/16
# broadcast 10.2.255.255

auto eth0.30
iface eth0.30 inet manual
  vlan-raw-device eth0
# address 10.3.'$IP'
# network 10.3.0.0/20
# broadcast 10.3.15.255
' \
| sudo tee /etc/network/interfaces.d/vlans

### update dhcpcd.conf (append)
echo \
'
interface eth0
static ip_address=10.0.'$IP'/22
static routers=10.0.0.1
static domain_name_servers=127.0.0.1#5335

#interface eth0.86
#static ip_address=10.0.'$IP'/22
#static routers=10.0.0.1
#static domain_name_servers=127.0.0.1#5335

interface eth0.10
static ip_address=10.1.'$IP'/22
static routers=10.1.0.1
static domain_name_servers=127.0.0.1#5335

interface eth0.20
static ip_addresses=10.2.'$IP'/16
static routers=10.2.0.1
static domain_name_servers=127.0.0.1#5335

interface eth0.30
static ip_addresses=10.3.'$IP'/20
static routers=10.3.0.1
static domain_name_servers=127.0.0.1#5335
' \
| sudo tee -a /etc/dhcpcd.conf

### update dnsmasq
# make backup if file exists
[ -f "/etc/dnsmasq.d/99-interfaces.conf" ] \
    && cp /etc/dnsmasq.d/99-interfaces.conf /etc/dnsmasq.d/99-interfaces.conf.old


echo \
'interface=eth0
#interface=eth0.86  # this is the native vlan
interface=eth0.10
interface=eth0.20
interface=eth0.30
' \
| sudo tee /etc/dnsmasq.d/99-interfaces.conf


### Cleanup & Reminders ###
echo "Have you trunked the switch port to the pi???"
echo "Pihole is rebooting..."
sudo reboot