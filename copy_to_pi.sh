#!/bin/bash

# run from admin computer
read -p "Input target <IP>: " IP
read -p "Input <USERNAME> @ <target>: " USER

ssh ${USER}@${IP} 'mkdir -p /home/pi/scripts && mkdir -p /home/pi/.secrets/certbot && mkdir -p /home/pi/keepalived'

scp ./setup/* ${USER}@${IP}:/home/${USER}/
# scp ./0\ -\ setup_host.sh ${USER}@${IP}:/home/${USER}/
# scp ./1\ -\ setup_log2ram.sh ${USER}@${IP}:/home/${USER}/
# scp ./2\ -\ setup_pihole.sh ${USER}@${IP}:/home/${USER}/
# scp ./3\ -\ setup_vlan.sh ${USER}@${IP}:/home/${USER}/
# scp ./4\ -\ setup_letsencrypt.sh ${USER}@${IP}:/home/${USER}/
# scp ./5\ -\ setup_keepalived.sh ${USER}@${IP}:/home/${USER}/

scp ./scripts/* ${USER}@${IP}:/home/${USER}/scripts/
# scp ./scripts/stats.py ${USER}@${IP}:/home/${USER}/scripts/
# scp ./scripts/stats.service ${USER}@${IP}:/home/${USER}/scripts/
# scp ./scripts/shutdown.py ${USER}@${IP}:/home/${USER}/scripts/
# scp ./scripts/shutdown.service ${USER}@${IP}:/home/${USER}/scripts/
# scp ./scripts/deploy-certs-4-pihole.sh ${USER}@${IP}:/home/${USER}/scripts/

# ssh ${USER}@${IP} 'mkdir -p /home/pi/.secrets/certbot' &&
scp ./.secrets/cloudflare.ini ${USER}@${IP}:/home/${USER}/.secrets/certbot/

scp ./keepalived/* ${USER}@${IP}:/home/${USER}/keepalived/
# scp ./keepalived/keepalived-main.conf ${USER}@${IP}:/home/${USER}/keepalived/
# scp ./keepalived/keepalived-secondary.conf ${USER}@${IP}:/home/${USER}/keepalived/
# scp ./keepalived/check_ftl.sh ${USER}@${IP}:/home/${USER}/keepalived/
# scp ./keepalived/restart_dns.sh ${USER}@${IP}:/home/${USER}/keepalived/
