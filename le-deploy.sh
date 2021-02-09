#!/bin/bash
# assumes will be run as root from crontab
# `47 3 * * * root /root/certbot-auto renew --quiet --no-self-upgrade --deploy-hook /usr/bin/le_deploy.sh`
cat /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/privkey.pem \
        /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/cert.pem | \
tee /etc/letsencrypt/live/${HOSTNAME}.ninerealmlabs.com/combined.pem

systemctl reload-or-try-restart lighttpd