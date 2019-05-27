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
    * `sudo pip3 install adafruit-blinka`
    * `sudo pip3 install adafruit-circuitpython-ssd1306`
    * `sudo apt-get install python3-pil`
    * see other setup steps and scripts from linked page
4. Set up log2rm (https://github.com/azlux/log2ram) to avoid burning out SD card writing queries
5. Set up shutdown/reboot button (inspiration from https://scruss.com/blog/2017/10/21/combined-restart-shutdown-button-for-raspberry-pi/):
    * `sudo apt-get install python3-gpiozero`
    * use `nano ~pi/shutdown.py` to enter editor
    * paste code below, then use **ctrl-o** to save and **ctrl-x** to exit
      ```
      #!/usr/bin/python3
      # -*- coding: utf-8 -*-
      # example gpiozero code that could be used to have a reboot
      #  and a shutdown function on one GPIO button
      # scruss - 2017-10, ahgraber - 2019-04

      use_button=21                       # rightmost top/bottom pins on PiZero

      from gpiozero import Button
      from signal import pause
      from subprocess import check_call

      held_for=0.0

      def rls():
              global held_for
              if (held_for > 5.0):       # power off if long hold
                      check_call(['sudo','shutdown','-h','now'])
              elif (held_for > 2.0):     # restart if short hold
                      check_call(['sudo','shutdown','-r','now'])
              else:
               held_for = 0.0

      def hld():
              # callback for when button is held
              #  is called every hold_time seconds
              global held_for
              # need to use max() as held_time resets to zero on last callback
              held_for = max(held_for, button.held_time + button.hold_time)

      button=Button(use_button, hold_time=1.0, hold_repeat=True)
      button.when_held = hld
      button.when_released = rls

      pause() # wait forever
      ```
    * as with the stats.py script, add `sudo shutdown.py &` to the bottom of rc.local with `sudo nano /etc/rc.local`
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
