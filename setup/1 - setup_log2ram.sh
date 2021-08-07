#!/bin/bash
# script to set up 'default' log2ram for pihole
# ref: https://github.com/azlux/log2ram

### install with apt
echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
sudo apt update
sudo apt install log2ram

### to uninstall
# apt remove log2ram --purge
# chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh

# reboot
echo "pihole is rebooting..."
sudo reboot
