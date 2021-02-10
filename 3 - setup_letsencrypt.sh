#!/bin/bash
# script to set up letsencrypt ssl certificates

# initial setup
NAME=`hostname`

# change permissions on copied files
chown $(whoami):$(whoami) ~/.secrets/certbot/cloudflare.ini 
sudo chmod 0700 ~/.secrets/
sudo chmod 400 ~/.secrets/certbot/cloudflare.ini

##########################
###   set up certbot   ###
##########################
echo "Installing certbot..."
sudo apt install certbot python3-certbot-dns-cloudflare -y
pip3 install --upgrade certbot certbot-dns-cloudflare cloudflare

################################
###   set up deploy script   ###
################################
echo \
'#!/bin/bash
# assumes certbot will be run as root from crontab
# place script in /etc/letsencrypt/renewal-hooks/deploy for autorun
# `47 3 * * * root /root/certbot-auto renew --noninteractive --quiet --no-self-$
cat /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/privkey.pem \
        /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/cert.pem | \
tee /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/combined.pem

systemctl reload-or-try-restart lighttpd
' \
| sudo tee /etc/letsencrypt/renewal-hooks/deploy/deploy-certs-4-pihole.sh
sudo chmod 775 /etc/letsencrypt/renewal-hooks/deploy/deploy-certs-4-pihole.sh

############################
###   get certificates   ###
############################
# certbot certonly --webroot -w /var/www/html -d $NAME.ninerealmlabs.com --dry-run
# note: use absolute path for cloudflare.ini
echo "Generating certificate with LetsEncrypt..."
sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /home/pi/.secrets/certbot/cloudflare.ini \
  --dns-cloudflare-propagation-seconds 60 \
  -d $HOSTNAME.ninerealmlabs.com

# test renewal
sudo certbot renew --dry-run

# add to crontab (find and replace existing certbot script with grep)
( crontab -l 2> /dev/null | grep -Fv certbot ; \
printf -- "47 3 * * * root certbot renew --noninteractive --quiet --no-self-upgrade\n" ) \
| crontab


#########################################
###   enable https in web interface   ###
#########################################
echo "Enabling HTTPS redirection..."
# ensure packages are updated
# sudo apt install --upgrade php7.3-common php7.3-cgi php7.3

# create combined certificate
sudo cat /etc/letsencrypt/live/$HOSTNAME.ninerealmlabs.com/privkey.pem \
        /etc/letsencrypt/live/$HOSTNAME.ninerealmlabs.com/cert.pem | \
sudo tee /etc/letsencrypt/live/$HOSTNAME.ninerealmlabs.com/combined.pem

# ensure lightpd user 'www-data' can read certs
sudo chown www-data -R /etc/letsencrypt/live

### copy into /etc/lighttpd/external.conf
# create backup
[ -f "/etc/lighttpd/external.conf" ] \
    && sudo cp /etc/lighttpd/external.conf \
    /etc/lighttpd/external.conf.old

echo \
'
$HTTP["host"] == "'${HOSTNAME}'.ninerealmlabs.com" {
  # Ensure the Pi-hole Block Page knows that this is not a blocked domain
  setenv.add-environment = ("fqdn" => "true")

  # Enable the SSL engine with a LE cert, only for this specific host
  $SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/letsencrypt/live/'${HOSTNAME}'.ninerealmlabs.com/combined.pem"
    ssl.ca-file =  "/etc/letsencrypt/live/'${HOSTNAME}'.ninerealmlabs.com/chain.pem"
    ssl.honor-cipher-order = "enable"
    ssl.cipher-list = "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH"
    ssl.use-sslv2 = "disable"
    ssl.use-sslv3 = "disable"
  }

  # Redirect HTTP to HTTPS
  $HTTP["scheme"] == "http" {
    $HTTP["host"] =~ ".*" {
      url.redirect = (".*" => "https://%0$0")
    }
  }
}
' \
| sudo tee /etc/lighttpd/external.conf

echo "Restarting lighttpd web server..."
# restart web server
sudo systemctl restart lighttpd.service
# sudo service  lighttpd restart

echo "If you get a lighttpd error, you may want to try running 'pihole -r'"
echo "LetsEncrypt script complete.  Consider rebooting."