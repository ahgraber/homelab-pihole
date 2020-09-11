#!/bin/bash

# run from admin computer
read -p "Input target <IP>: " IP
read -p "Input <USERNAME> @ <target>: " USER

scp ./0\ -\ setup_host.sh $USER@$IP:/home/$USER/
scp ./1\ -\ setup_pihole.sh $USER@$IP:/home/$USER/
scp ./2\ -\ setup_vlan.sh $USER@$IP:/home/$USER/
scp ./3\ -\ setup_letsencrypt.sh $USER@$IP:/home/$USER/

ssh $USER@$IP 'mkdir -p /home/pi/.secrets/certbot' && scp ./cloudflare.ini $USER@$IP:/home/$USER/.secrets/certbot/
scp ./4\ -\ setup_log2ram.sh $USER@$IP:/home/$USER/
scp ./stats.py $USER@$IP:/home/$USER/
scp ./stats.service $USER@$IP:/home/$USER/
