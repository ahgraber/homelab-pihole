#!/bin/bash

##################
###   update   ###
##################
echo "Updating pi..."
sudo apt update && sudo apt upgrade -y

##############################
###   install keepalived   ###
##############################
echo "Installing keepalived..."
sudo apt install keepalived ipset -y
sudo systemctl enable keepalived.service

###########################
###   install scripts   ###
###########################
echo 'Installing keepalived scripts...'
sudo mkdir -p /etc/keepalived
sudo cp /home/pi/keepalived/check_ftl.sh /etc/keepalived/check_ftl.sh
sudo chmod 755 /etc/keepalived/check_ftl.sh

sudo cp /home/pi/keepalived/restart_dns.sh /etc/keepalived/restart_dns.sh
sudo chmod 755 /etc/keepalived/restart_dns.sh

###################################
###   Install keepalived.conf   ###
###################################
read -p "Will this be MAIN or BACKUP? (m/b): " CHOICE
case "$CHOICE" in
  m | M) MAIN=true ;;
  b | B) MAIN=false ;;
  *) echo "invalid" ;;
esac

if [ $MAIN = true ]; then
  echo "Installing MAIN keepalived.conf..."
  sudo cp /home/pi/keepalived/keepalived-main.conf /etc/keepalived/keepalived.conf
else
  echo "Installing BACKUP keepalived.conf..."
  sudo cp /home/pi/keepalived/keepalived-secondary.conf /etc/keepalived/keepalived.conf
fi

###########################################
###   Add startup delay to keepalived   ###
###########################################
echo 'Adding startup delay...'
sudo sed -i -e'/EnvironmentFile=/a\' -e 'ExecStartPre=/bin/sleep 60' /lib/systemd/system/keepalived.service

##############################
###   restart keepalived   ###
##############################
echo 'Restarting keepalived...'
sudo systemctl daemon-reload
sudo systemctl restart keepalived.service
