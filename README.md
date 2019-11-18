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
2. Install PiHole (https://learn.adafruit.com/pi-hole-ad-blocker-with-pi-zero-w?view=all#install-pi-hole)
3. Set up PiOLED (https://learn.adafruit.com/pi-hole-ad-blocker-with-pi-zero-w?view=all#install-pioled)  
  Supporting installs include:
    * `sudo apt-get install python3-pip`
    * `sudo pip3 install RPI.GPIO`
    * `sudo pip3 install gpiozero`
    * `sudo pip3 install adafruit-blinka`
    * `sudo pip3 install adafruit-circuitpython-ssd1306`
    * `sudo apt-get install python3-pil`
    * see other setup steps and scripts from linked page; https://github.com/ahgraber/pihole/blob/master/stats.py
4. Set up log2rm (https://github.com/azlux/log2ram) to avoid burning out SD card writing queries
5. Set up shutdown/reboot button (inspiration from https://scruss.com/blog/2017/10/21/combined-restart-shutdown-button-for-raspberry-pi/) with shutdown.py script: 
    * https://github.com/ahgraber/pihole/blob/master/shutdown.py
    * create shutdown service for systemctl (see https://github.com/ahgraber/pihole/blob/master/shutdown.service) and copy to location with `sudo cp shutdown.service /etc/systemd/system/shutdown.service`
    * start service with `sudo systemctl start shutdown.service`  
    * set shutdown service to run on startup with `sudo systemctl enable shutdown.service`  
    * set stats service to run on startup with `sudo systemctl enable stats.service`
    
    * reboot and see if shutdown.py script is running with `ps -aef | grep python`.  If it is, try shorting out the rightmost top and bottom pins to test reboot/shut down
    * if everything is good, solder the momentary switch between the rightmost top and bottom pins.
6. Back up the card! (https://computers.tutsplus.com/articles/how-to-clone-raspberry-pi-sd-cards-using-the-command-line-in-os-x--mac-59911)

## Common references
* Log in with `ssh pi@<raspberry_pi_name>.local`
* Restart with `sudo shutdown -r now`
* Shut down with `sudo shutdown -h now`
* Check what python scripts are running with `ps -aef | grep python`

## Router + Pihole setup 
(see also https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245)
_assuming using Tomato/AdvancedTomato_  
**On Router**  
* Set two static upstream DNS servers in Basic > Network > LAN > Static DNS. Save your changes.  
* UNcheck "Use received DNS with user-entered DNS", & check "Intercept DNS port (UDP 53)". 
* Keep "dhcp-option=6,<pi-hole_IP_address> under "Dnsmasq custom configuration". Save your changes again.
**On Pihole**  
* Log into your pi-hole and head to Settings > DNS > Upstream DNS Servers. Under "Custom 1 (IPv4)", check the box and enter "192.168.1.1". Leave ALL the other providers unchecked.

Note: *__optional__* Enable DNS over HTTPS (https://docs.pi-hole.net/guides/dns-over-https/) - this breaks the dnsmasq that allows host identification in admin console.
