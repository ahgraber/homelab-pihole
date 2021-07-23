#!/bin/bash

# script to run initial setup on host:
# runs initial host setup

# set hostname
read -p "Please provide hostname: " NAME
read -p "Please provide target IP (10.0.__.__): " IP

###############################
###   convenience aliases   ###
###############################
echo \
'alias ls="ls -A --color=auto"
alias whatismyip="curl ifconfig.co"
alias externalip="curl ifconfig.co"
' \
| sudo tee --append /home/pi/.bash_aliases


###############################
###   clean host identity   ###
###############################
# wipe home directory of folders
rm -rf /home/pi/Bookshelf/
rm -rf /home/pi/Desktop/
rm -rf /home/pi/Documents/
rm -rf /home/pi/Downloads/
rm -rf /home/pi/Music/
rm -rf /home/pi/Pictures/
rm -rf /home/pi/Public/
rm -rf /home/pi/Templates/
rm -rf /home/pi/Videos/

# reset password
read -p "Reset password? (y/n): " RESET_PWD
case "$RESET_PWD" in 
  y|Y ) passwd;;
  n|N ) echo "Password unchanged.";;
  * ) echo "invalid";;
esac


# update time zone
sudo timedatectl set-timezone America/New_York
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timedated
sudo systemctl restart systemd-timesyncd

# WARNING: this will overwrite and replace /etc/systemd/timesyncd.conf!
# make backup if file exists
[ -f "/etc/systemd/timesyncd.conf" ] \
    && sudo cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.old
echo \
'
[Time]
NTP=10.0.0.1 10.1.0.1
#FallbackNTP=0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048
' \
| sudo tee /etc/systemd/timesyncd.conf

# update hostname
sudo hostnamectl set-hostname $NAME

# WARNING: this will overwrite and replace /etc/hosts!
# make backup if file exists
[ -f "/etc/hosts" ] \
    && sudo cp /etc/hosts /etc/hosts.old

echo \
'
10.0.'$IP'       '$NAME'.ninerealmlabs.com '$NAME'
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       '$NAME \
| sudo tee /etc/hosts


#################################
###   inital network config   ###
#################################
echo \
'
interface eth0
    static ip_address=10.0.'$IP'/22
    static routers=10.0.0.1
    static domain_name_servers=1.1.1.1 1.0.0.1
' \
| sudo tee --append /etc/dhcpcd.conf


echo "pi is rebooting..."
sudo reboot
