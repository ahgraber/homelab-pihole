#!/bin/bash

# script to install pihole on host:
# updates
# installs firewall
# installs pihole
# installs unbound
# installs pioled

##################
###   update   ###
##################
echo "Updating pi..."
sudo apt update && sudo apt upgrade -y


################################
###   install ufw firewall   ###
################################
echo "\nInstalling ufw firewall..."
sudo apt install ufw
# set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing
    ### port restrictions
# allow ssh access
sudo ufw allow from 10.0.0.0/8 to any port 22
sudo ufw limit ssh/tcp
# for webui
sudo ufw allow from 10.0.0.0/8 to any port 80,443 proto tcp
# for dns
sudo ufw allow from 10.0.0.0/8 to any port 53 proto tcp
sudo ufw allow from 10.0.0.0/8 to any port 53 proto udp
# for dhcp
sudo ufw allow from 10.0.0.0/8 to any port 67 proto tcp
sudo ufw allow from 10.0.0.0/8 to any port 67 proto udp
# for igmp
sudo ufw allow from 10.0.0.0/8 to any proto igmp

sudo ufw enable
sudo ufw status


############################
###   install fail2ban   ###
############################
echo "\nInstalling fail2ban..."
sudo apt install fail2ban


##########################
###   install pihole   ###
##########################
echo "\nInstalling pihole..."
curl -sSL https://install.pi-hole.net | bash

# change default web admin password
echo "\nUpdate pihole password:"
sudo pihole -a -p


###########################
###   install unbound   ###
###########################
echo "\Installing unbound..."
sudo apt install unbound

# create logging location
sudo mkdir -p /var/log/unbound
sudo touch /var/log/unbound/unbound.log
sudo chown unbound /var/log/unbound/unbound.log

# configure
# WARNING: this will overwrite and replace /etc/unbound/unbound.conf.d/pi-hole.conf!
# make backup if file exists
[ -f "/etc/unbound/unbound.conf.d/pi-hole.conf" ] \
    && sudo cp /etc/unbound/unbound.conf.d/pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf.old

echo \
'
server:
    # If no logfile is specified, syslog is used
    # logfile: "/var/log/unbound/unbound.log"
    verbosity: 0

    interface: 127.0.0.1
    # NOTE: "interface: 0.0.0.0" would make Unbound listen on all IPs 
    # configured for the Pi rather than just localhost (127.0.0.1) 
    # so that other machines on the local network can access DNS on the Pi

    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # May be set to yes if you have IPv6 connectivity
    do-ip6: no

    # You want to leave this to no unless you have *native* IPv6. With 6to4 and
    # Terredo tunnels your web browser should favor IPv4 for the same reasons
    prefer-ip6: no

    # Use this only when you downloaded the list of primary root servers!
    # If you use the default dns-root-data package, unbound will find it automatically
    #root-hints: "/var/lib/unbound/root.hints"

    # Trust glue only if it is within the servers authority
    harden-glue: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
    harden-dnssec-stripped: yes

    # Dont use Capitalization randomization as it known to cause DNSSEC issues sometimes
    # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
    use-caps-for-id: no

    # Reduce EDNS reassembly buffer size.
    # Suggested by the unbound man page to reduce fragmentation reassembly problems
    edns-buffer-size: 1472

    # Perform prefetching of close to expired message cache entries
    # This only applies to domains that have been frequently queried
    prefetch: yes

    # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine, it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
    num-threads: 1

    # Ensure kernel buffer is large enough to not lose messages in traffic spikes
    so-rcvbuf: 1m

    # Ensure privacy of local IP ranges
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10

    # set access control
    access-control: 10.0.0.0/8 allow

# set up unbound to use cloudflare dns-over-tls
forward-zone:
    name: "."
    forward-addr: 1.1.1.1@853  #cloudflare-dns.com
    forward-addr: 1.0.0.1@853  #cloudflare-dns.com
    forward-ssl-upstream: yes
' \
| sudo tee /etc/unbound/unbound.conf.d/pi-hole.conf

# restart unbound with new configuration
sudo service unbound restart

# set pihole to use unbound
echo "\nReconfiguring pihole to use unbound:"
echo "Set dns to 127.0.0.1#5335"
read -p "Press any key to continue..." input
pihole -r

#########################################
###   set up conditional forwarding   ###
#########################################
echo "Setting up standard conditional forwarding..."

# WARNING: this will overwrite and replace /etc/dnsmasq.d/01-pihole.conf!
# make backup if file exists
[ -f "/etc/dnsmasq.d/01-pihole.conf" ] \
    && sudo cp /etc/dnsmasq.d/01-pihole.conf /etc/dnsmasq.d/01-pihole.conf.old
echo \
'
rev-server=10.0.0.0/8,10.0.0.1
server=/ninerealmlabs.com/10.0.0.1
' \
| sudo tee --append /etc/dnsmasq.d/01-pihole.conf


read -p "Set up additional conditional forwarding (y/n):?" CHOICE
case "$CHOICE" in 
  y|Y ) ADDITIONAL_CONDITIONAL=true;;
  n|N ) ADDITIONAL_CONDITIONAL=false;;
  * ) echo "invalid";;
esac

if [ $ADDITIONAL_CONDITIONAL = true]; then
    # WARNING: this will overwrite and replace /etc/dnsmasq.d/02-custom.conf!
    # make backup if file exists
    [ -f "/etc/dnsmasq.d/02-custom.conf" ] \
        && sudo cp /etc/dnsmasq.d/02-custom.conf /etc/dnsmasq.d/02-custom.conf.old

    # tell pihole to forward all requests for domain to router
    echo \
    '
    server=/pihole.ninerealmlabs.com/10.0.0.1
    server=/pi-hole.ninerealmlabs.com/10.0.0.1
    server=/homeassistant.ninerealmlabs.com/10.3.0.1

    server=/0.10.in-addr.arpa/10.0.0.1
    server=/1.10.in-addr.arpa/10.1.0.1
    server=/2.10.in-addr.arpa/10.2.0.1
    server=/3.10.in-addr.arpa/10.3.0.1

    # more specific lookup example
    # server=/ubuntu.muspellheimxi.ninerealmlabs.com/10.2.2.1
    ' \
    | sudo tee /etc/dnsmasq.d/02-custom.conf
fi


###########################
###   install display   ###
###########################
# install dependencies
echo "\n Installing display..."
sudo apt install python3-pip
sudo pip3 install RPI.GPIO gpiozero adafruit-blinka adafruit-circuitpython-ssd1306
sudo apt install python3-pil
wget http://kottke.org/plus/type/silkscreen/download/silkscreen.zip
unzip silkscreen.zip
rm silkscreen.zip && rm readme.txt && rm -r __MACOSX/

# create service
sudo cp stats.service /etc/systemd/system/stats.service \
&& sudo systemctl start stats.service \
&& sudo systemctl enable stats.service  


##########################
###   clean & reboot   ###
##########################
echo "pihole is rebooting..."
sudo reboot