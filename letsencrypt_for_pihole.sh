#! /etc/bash

NAME=$(hostname)
# create combined certificate
sudo cat /etc/letsencrypt/live/$NAME.ninerealmlabs.com/privkey.pem \
        /etc/letsencrypt/live/$NAME.ninerealmlabs.com/cert.pem | \
sudo tee /etc/letsencrypt/live/$NAME.ninerealmlabs.com/combined.pem

# ensure lightpd user 'www-data' can read certs
sudo chown www-data -R /etc/letsencrypt/live

### copy into /etc/lighttpd/external.conf
# create backup
[ -f "/etc/lighttpd/external.conf" ] \
    && sudo cp /etc/lighttpd/external.conf \
    /etc/lighttpd/external.conf.old

echo \
'
$HTTP["host"] == "'$NAME'.ninerealmlabs.com" {
  # Ensure the Pi-hole Block Page knows that this is not a blocked domain
  setenv.add-environment = ("fqdn" => "true")

  # Enable the SSL engine with a LE cert, only for this specific host
  $SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/letsencrypt/live/'$NAME'.ninerealmlabs.com/combined.pem"
    ssl.ca-file =  "/etc/letsencrypt/live/'$NAME'.ninerealmlabs.com/chain.pem"
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