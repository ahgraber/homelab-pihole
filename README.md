# pihole

## Equipment:
1. Raspberry Pi Zero W (https://www.adafruit.com/product/3409) 
2. Colored header for Pi Zero (https://www.adafruit.com/product/3907)
3. *__optional__* microUSB to ethernet dongle (https://www.amazon.com/gp/product/B00RM3KXAU/)
4. *__optional__* PiOLED 128x32 screen (https://www.adafruit.com/product/3527) 
5. *__optional__* momentary switch (something like these: https://www.amazon.com/Cylewet-Momentary-Button-Switch-CYT1078/dp/B0752RMB7Q/)

## Instructions (follow Adafruit guide):
1. Set up Raspberry Pi (https://learn.adafruit.com/pi-hole-ad-blocker-with-pi-zero-w?view=all#prepare-the-pi)
    * If your router has usb that provides sufficient power, power your pi from the usb out on the router
    * Plug ethernet in if you have the optional dongle
    * Set your router to provide the pi with a static IP address
2. Follow [Host Setup instructions](https://github.com/ahgraber/homelab-pihole/blob/develop/0%20-%20Host%20setup.md)
3. Update 0-setup_host.sh, 1-setup_vlan.sh to customize hostname, network IPs
3. Run shell scripts 0-2:
    * 0-setup_host.sh: Sets up rpi hostname, firewall, pihole, unbound, and adafruit display
    * 1-setup_vlan.sh: Sets up vlan interfaces for rpi
    * (optional) 2-setup_log2ram.sh: Sets up ramdrive & logging
4. Review [DNS Setup notes]((https://github.com/ahgraber/homelab-pihole/blob/develop/2%20-%20DNS%20setup.md) for conditional forwarding
5. Set up shutdown/reboot button (inspiration from https://scruss.com/blog/2017/10/21/combined-restart-shutdown-button-for-raspberry-pi/) with shutdown.py script: 
    * https://github.com/ahgraber/pihole/blob/master/shutdown.py
    * create shutdown service for systemctl (see https://github.com/ahgraber/pihole/blob/master/shutdown.service) and copy to location with `sudo cp shutdown.service /etc/systemd/system/shutdown.service`
    * start service with `sudo systemctl start shutdown.service`  
    * set shutdown service to run on startup with `sudo systemctl enable shutdown.service`  
    * set stats service to run on startup with `sudo systemctl enable stats.service`
6. Back up the card! (https://computers.tutsplus.com/articles/how-to-clone-raspberry-pi-sd-cards-using-the-command-line-in-os-x--mac-59911)
