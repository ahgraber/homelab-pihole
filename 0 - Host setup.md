# Host setup

From a fresh Raspbian OS install:
1. Make sure there is a blank file 'ssh' at the root: ```touch ssh```
2. Boot pi & confirm ssh works
3. From ADMIN: 
   1. Copy SSH keys:
   ```ssh-copy-id -i ~/.ssh/ahgraber_id_rsa.pub <username>@<server ip>```
   ```ssh-copy-id -i ~/.ssh/ahg_ninerealmlabs_id_rsa.pub <username>@<server ip>```
   2. Copy files (from <git repo>/infrastructure/pihole/):
   ```scp ./0\ -\ setup_host.sh pi@<pihole.ip>:/home/pi/```
   ```scp ./1\ -\ setup_vlan.sh pi@<pihole.ip>:/home/pi/```
   ```scp ./2\ -\ setup_log2ram.sh pi@<pihole.ip>:/home/pi/```
   ```scp ./stats.py pi@<pihole.ip>:/home/pi/```
   ```scp ./stats.service pi@<pihole.ip>:/home/pi/```
4. SSH into pi:
   1. Run:
   ```sh 0\ -\ setup_host.sh``` to complete host setup, enable firewall, and install pihole
   ```sh 1\ -\ setup_vlan.sh``` to complete vlan setup