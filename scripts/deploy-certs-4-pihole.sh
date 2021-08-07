#!/bin/bash
# assumes certbot will be run as root from crontab
# place script in /etc/letsencrypt/renewal-hooks/deploy for autorun
# `47 3 * * * root /root/certbot-auto renew --noninteractive --quiet --no-self-$
cat /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/privkey.pem \
  /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/cert.pem \
  | tee /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/combined.pem

systemctl reload-or-try-restart lighttpd
