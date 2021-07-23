# pihole

## Equipment:
1. Raspberry Pi Zero W (https://www.adafruit.com/product/3409)
2. Colored header for Pi Zero (https://www.adafruit.com/product/3907)
3. *__optional__* microUSB to ethernet dongle (https://www.amazon.com/gp/product/B00RM3KXAU/)
4. *__optional__* PiOLED 128x32 screen (https://www.adafruit.com/product/3527)
5. *__optional__* momentary switch (something like these: https://www.amazon.com/Cylewet-Momentary-Button-Switch-CYT1078/dp/B0752RMB7Q/)

## Instructions:
### 0. [Set up Raspberry Pi](https://learn.adafruit.com/pi-hole-ad-blocker-with-pi-zero-w?view=all#prepare-the-pi)
    * If your router has usb that provides sufficient power, power your pi from the usb out on the router
    * Plug ethernet in if you have the optional dongle
    * Set your router to provide the pi with a static IP address

### 1. Host setup
From a fresh Raspbian OS install:
1. Make sure there is a blank file 'ssh' at the root: ```touch ssh```

2. Boot pi & confirm ssh works; disable wifi if connected via ethernet:
```sh
sudo sed -i -e '/# Additional overlays and parameters are documented/a\' -e 'dtoverlay=disable-bt' /boot/config.txt
sudo sed -i -e '/# Additional overlays and parameters are documented/a\' -e 'dtoverlay=disable-wifi' /boot/config.txt
sudo sed -i -e'/# Additional overlays and parameters are documented/a\' -e  '# Disable wifi' /boot/config.txt
```

1. From *local admin computer*:
    1. Copy SSH keys:
        ```ssh-copy-id -i ~/.ssh/ahgraber_id_rsa.pub <username>@<server ip>```
        ```ssh-copy-id -i ~/.ssh/ahg_ninerealmlabs_id_rsa.pub <username>@<server ip>```
    2. Copy files (from <git repo>/infrastructure/pihole/) by running ```sh copy_to_pi.sh```:

2. SSH into remote pi:
    1. *Update setup scripts to update internal ip addresses, since these are hardcoded*
    2. Run (*Do not run with `sudo`*):
        ```sh 0\ -\ setup_host.sh``` to complete host setup
        ```sh 1\ -\ setup_log2ramsh.``` to install log2ram
        ```sh 2\ -\ setup_pihole.sh``` to enable firewall, and install pihole
        ```sh 3\ -\ setup_vlan.sh``` to complete [vlan setup](https://engineerworkshop.com/blog/raspberry-pi-vlan-how-to-connect-your-rpi-to-multiple-networks/)
        *Don't forget to update the VLAN configuration on the router & switch!!!*
        ```sh 4\ -\ setup_letsencrypt.sh``` to complete letsencrypt certification
            * add `letsencrypt_for_pihole.sh` as crontab: `crontab -e`
                in crontab:
                ```
                2 4 * * * /path/to/letsencrypt_for_pihole.sh
                ```
        ```sh 5\ -\ setup_keepalived.sh``` to complete keepalived HA
            * use the keepalived virtual IP as the DNS source

3. Set up [shutdown/reboot button](https://scruss.com/blog/2017/10/21/combined-restart-shutdown-button-for-raspberry-pi/) with shutdown.py script:
    * https://github.com/ahgraber/pihole/blob/master/shutdown.py
    * create shutdown service for systemctl (see https://github.com/ahgraber/pihole/blob/master/shutdown.service)
        and copy to location with `sudo cp shutdown.service /etc/systemd/system/shutdown.service`
    * start service with `sudo systemctl start shutdown.service`
    * set shutdown service to run on startup with `sudo systemctl enable shutdown.service`
    * set stats service to run on startup with `sudo systemctl enable stats.service`

### 2. Pihole setup
#### Settings > DNS
1. Set: "Listen on all interfaces; permit all origins"
2. Uncheck / deselect:
   * [ ] "Never forward non-FQDNs"
   * [ ] "Never forward reverse lookups for private IP ranges"
3. Set up **conditional forwarding** to dhcp server / domain
4. [edit /etc/pihole/setupVars.conf](https://www.reddit.com/r/pihole/comments/a9ktnl/getting_pihole_to_do_reverse_lookup/) and add the reverse lookups:
    ```CONDITIONAL_FORWARDING_REVERSE=10.in-addr.arpa```
5. Run ```pihole -r``` to repair using the updated setupVars.conf file

#### Restore settings with Transporter

#### Pihole Blocklists
```
https://v.firebog.net/hosts/static/w3kbl.txt
https://v.firebog.net/hosts/AdguardDNS.txt
https://v.firebog.net/hosts/Admiral.txt
https://v.firebog.net/hosts/Easylist.txt
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://v.firebog.net/hosts/Prigent-Crypto.txt
https://v.firebog.net/hosts/Shalla-mal.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/CoinMiner.txt
https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt
```

### 3. Keep piholes in sync with [gravity sync](https://github.com/vmstan/gravity-sync)
<!-- * [pihole-cloudsync](https://github.com/stevejenkins/pihole-cloudsync) -->
1. Install on primary
```sh
export GS_INSTALL=primary && curl -sSL https://gravity.vmstan.com | bash
```
2. Install & configure on secondary
```sh
export GS_INSTALL=secondary && curl -sSL https://gravity.vmstan.com | bash
```
If re-configuration is necessary, run `~/gravity-sync/gravity-sync.sh config`
_**NOTE:** All further actions are taken FROM SECONDARY_
3. Compare & sync
```sh
cd ~/gravity-sync
./gravity-sync.sh compare

# to force pull from primary
./gravity-sync.sh pull

# to generic sync
./gravity-sync.sh smart
```
4. Automate
```sh
cd ~/gravity-sync
./gravity-sync.sh automate
```

### 4. Firewall Setup w/ OPNsense
#### OPNSense Unbound
1. Ensure `Unbound` DNS service is used

#### OPNSense General settings
1. In `System > Settings > General > Networking`:
   1. set DNS servers to pihole interfaces
   2. [x] "Do not use the local DNS service as a nameserver for this system"
2. In `DHCPv4` Service, set per-network DNS
3. In `Services > Unbound > General`:
   1. [x] "Register DHCP leases"
   2. [x] "Register DHCP static mappings"
   3. [x] "Enable Forwarding Mode"
   4. Local Zone: `typetransparent`


### 5. [Back up the card!](https://computers.tutsplus.com/articles/how-to-clone-raspberry-pi-sd-cards-using-the-command-line-in-os-x--mac-59911)
